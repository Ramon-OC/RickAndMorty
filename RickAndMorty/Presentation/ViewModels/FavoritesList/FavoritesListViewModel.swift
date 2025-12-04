//
//  FavoritesListViewModel.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Combine
import Foundation

@MainActor
final class FavoritesViewModel: ObservableObject, FavoriteNotificationObserver {
    @Published private(set) var favoriteCharacters: [Character] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isAuthenticated = false
    @Published var showError = false
    @Published private(set) var errorMessage: String?

    // Authentication State
    @Published private(set) var biometricAvailability: BiometricAvailability

    // Dependencies
    private let characterRepository: CharacterRepository
    private let authenticateUseCase: AuthenticateWithBiometricsProtocol
    private let checkAvailabilityUseCase: CheckBiometricAvailabilityProtocol
    private let biometricRepository: BiometricAuthRepository

    private var cancellables = Set<AnyCancellable>()
    private var authenticationTask: Task<Void, Never>?

    // init
    init(characterRepository: CharacterRepository, authenticateUseCase: AuthenticateWithBiometricsProtocol, checkAvailabilityUseCase: CheckBiometricAvailabilityProtocol, biometricRepository: BiometricAuthRepository) {
        self.characterRepository = characterRepository
        self.authenticateUseCase = authenticateUseCase
        self.checkAvailabilityUseCase = checkAvailabilityUseCase
        self.biometricRepository = biometricRepository

        biometricAvailability = checkAvailabilityUseCase.execute()
        cancellables = setupFavoriteNotifications()
    }

    // authentication
    func authenticate() {
        authenticationTask?.cancel() // si ya había uno antes, se cancela
        authenticationTask = Task { @MainActor in
            await performAuthentication()
        }
    }

    private func performAuthentication() async {
        guard biometricAvailability.canAuthenticate else { // must be available on the device
            handleAuthenticationError(.notAvailable)
            return
        }

        errorMessage = nil
        showError = false

        // do authentication
        let result = await authenticateUseCase.execute(
            reason: "Accede a la lista de tus personajes favoritos"
        )

        switch result {
        case let .success(authenticated):
            if authenticated {
                isAuthenticated = true
                await loadFavorites() // loads favorites until the user is successfully authenticated
            } else {
                handleAuthenticationError(.authenticationFailed)
            }

        case let .failure(error):
            handleAuthenticationError(error)
        }
    }

    // Load Favorites
    func loadFavorites() async {
        guard isAuthenticated else { return } // no authentication == no favorites loading

        isLoading = true
        defer { isLoading = false } // guarantees that the following will be executed before exiting the function

        let favorites = await characterRepository.getFavoriteCharacters()
        favoriteCharacters = favorites.sorted { $0.name < $1.name }
    }

    // Toggle Favorite
    func toggleFavorite(_ character: Character) async {
        do {
            try await characterRepository.toggleFavorite(characterId: character.id)

            let newFavoriteStatus = !character.isFavorite

            FavoriteNotificationManager.shared.notifyFavoriteStatusChanged(
                characterId: character.id,
                isFavorite: newFavoriteStatus,
                character: character
            )

            await loadFavorites()
        } catch {
            handleError("Error al actualizar un personaje favorito", error: error)
        }
    }

    // MARK: - Screen Lock

    func lockScreen() {
        invalidateAuthentication()
        isAuthenticated = false
        favoriteCharacters = [] // empty the list for security reasons (will load all again when user wants)
    }

    func invalidateAuthentication() {
        biometricRepository.invalidateAuthentication()
    }

    func retryAuthentication() {
        biometricAvailability = checkAvailabilityUseCase.execute()
        errorMessage = nil
        showError = false
        authenticate()
    }

    // Error Handling
    private func handleAuthenticationError(_ error: BiometricAuthError) {
        switch error {
        case .userCancel:
            showError = false
            // do nothing (ignore)

        case .authenticationFailed:
            if error.isRecoverable {
                errorMessage = error.errorDescription
                showError = true
            }

        case .notAvailable, .notEnrolled, .passcodeNotSet:
            errorMessage = error.errorDescription
            showError = true

        case .biometryLockout:
            errorMessage = error.errorDescription
            showError = true

        default:
            errorMessage = error.errorDescription
            showError = true
        }
    }

    private func handleError(_ context: String, error: Error) {
        errorMessage = "\(context): \(error.localizedDescription)"
        showError = true
    }

    // MARK: - Favorite Notification Observer

    func handleFavoriteStatusChanged(characterId: Int, isFavorite: Bool, character: Character?) {
        if isFavorite {
            if !favoriteCharacters.contains(where: { $0.id == characterId }),
               let character = character
            {
                var updatedCharacter = character
                updatedCharacter.isFavorite = true
                favoriteCharacters.append(updatedCharacter)
                favoriteCharacters.sort { $0.name < $1.name }
            }
        } else {
            favoriteCharacters.removeAll { $0.id == characterId }
        }
    }

    func handleFavoritesListUpdated() {
        if isAuthenticated {
            Task {
                await loadFavorites()
            }
        }
    }
}
