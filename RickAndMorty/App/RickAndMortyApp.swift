//
//  RickAndMortyApp.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

@main
struct RickAndMortyApp: App {
    init() {
        StringArrayTransformer.register()
    }

    // MARK: - Persistence

    let persistenceController = CoreDataStack.shared

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some View {
        TabBarView()
    }
}

// MARK: - Tab Bar View

struct TabBarView: View {
    @State private var selectedTab = 0

    private let dependencies = AppDependencies.shared

    @StateObject private var favoritesVM =
        AppDependencies.shared.makeFavoritesViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            CharacterListView()
                .tabItem { Label("Personajes", systemImage: "person.3.fill") }
                .tag(0)

            MapView(getCachedCharactersUseCase: dependencies.makeGetCachedCharactersUseCase())
                .tabItem { Label("Mapa", systemImage: "map.fill") }
                .tag(1)

            FavoritesListView(viewModel: favoritesVM)
                .tabItem { Label("Favoritos", systemImage: "star.fill") }
                .tag(2)
        }
        .tint(.blue)
    }
}

// MARK: - Dependency Container

final class AppDependencies {
    static let shared = AppDependencies()

    // MARK: - Core Data

    private let coreDataStack: CoreDataStack

    // MARK: - Repositories

    private let characterRepository: CharacterRepository
    private let episodeRepository: EpisodeRepository
    private let biometricRepository: BiometricAuthRepository

    // MARK: - Use Cases

    private let authenticateUseCase: AuthenticateWithBiometricsProtocol
    private let checkAvailabilityUseCase: CheckBiometricAvailabilityProtocol

    private init() {
        // Initialize Core Data
        coreDataStack = CoreDataStack.shared

        // Initialize Repositories
        characterRepository = CharacterRepositoryImpl(
            coreDataStack: coreDataStack
        )
        episodeRepository = EpisodeRepositoryImpl(
            coreDataStack: coreDataStack
        )
        biometricRepository = BiometricAuthRepositoryImpl()

        // Initialize Use Cases
        authenticateUseCase = AuthenticateWithBiometrics(
            repository: biometricRepository
        )
        checkAvailabilityUseCase = CheckBiometricAvailability(
            repository: biometricRepository
        )
    }

    // MARK: - Factory Methods

    func makeFavoritesViewModel() -> FavoritesViewModel {
        FavoritesViewModel(
            characterRepository: characterRepository,
            authenticateUseCase: authenticateUseCase,
            checkAvailabilityUseCase: checkAvailabilityUseCase,
            biometricRepository: biometricRepository
        )
    }

    func makeGetCachedCharactersUseCase() -> GetCachedCharactersProtocol {
        GetCachedCharacters(repository: characterRepository)
    }
}

// MARK: - Preview

#Preview("Main App") {
    MainTabView()
        .environment(\.managedObjectContext, CoreDataStack.shared.viewContext)
}
