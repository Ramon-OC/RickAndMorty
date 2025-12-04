//
//  CharacterListViewModel.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Combine
import Foundation

@MainActor
final class CharacterListViewModel: ObservableObject, FavoriteNotificationObserver {
    @Published private(set) var characters: [Character] = []
    @Published private(set) var state: ViewState<[Character]> = .idle
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMorePages = true
    @Published var searchText = ""
    @Published var selectedStatus: CharacterStatus?
    @Published var selectedSpecies: String = ""
    @Published var showFilters = false

    private var currentPage = 1
    private var totalPages = 1
    private let getCharactersUseCase: GetCharactersProtocol
    private let getCachedCharactersUseCase: GetCachedCharactersProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    // computed properties
    var currentFilter: CharacterFilter {
        CharacterFilter(
            name: searchText.isEmpty ? nil : searchText,
            status: selectedStatus,
            species: selectedSpecies.isEmpty ? nil : selectedSpecies
        )
    }

    var hasActiveFilters: Bool {
        selectedStatus != nil || !selectedSpecies.isEmpty
    }

    init(getCharactersUseCase: GetCharactersProtocol, getCachedCharactersUseCase: GetCachedCharactersProtocol) {
        self.getCharactersUseCase = getCharactersUseCase
        self.getCachedCharactersUseCase = getCachedCharactersUseCase

        setupSearchDebounce()

        let favoriteNotificationCancellables = setupFavoriteNotifications()
        cancellables.formUnion(favoriteNotificationCancellables)
    }

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.searchTask?.cancel()
                self?.searchTask = Task { [weak self] in
                    await self?.resetAndLoad()
                }
            }
            .store(in: &cancellables)
    }

    // Public Methods
    func loadInitialData() async {
        guard case .idle = state else { return }
        await loadCharacters(reset: true)
    }

    func refresh() async {
        await loadCharacters(reset: true)
    }

    func loadMoreIfNeeded(currentItem: Character) async {
        guard let lastItem = characters.last,
              currentItem.id == lastItem.id,
              hasMorePages,
              !isLoadingMore else { return }

        await loadMoreCharacters()
    }

    func applyFilters() async {
        showFilters = false
        await resetAndLoad()
    }

    func clearFilters() async {
        selectedStatus = nil
        selectedSpecies = ""
        showFilters = false
        await resetAndLoad()
    }

    func updateCharacterFavorite(id: Int, isFavorite: Bool) {
        if let index = characters.firstIndex(where: { $0.id == id }) {
            characters[index].isFavorite = isFavorite
        }
    }

    // Private Methods
    private func resetAndLoad() async {
        currentPage = 1
        characters = []
        hasMorePages = true
        await loadCharacters(reset: true)
    }

    private func loadCharacters(reset: Bool) async {
        if reset {
            state = .loading
        }

        do {
            let page = try await getCharactersUseCase.execute(
                page: currentPage,
                filter: currentFilter
            )

            if reset {
                characters = page.characters
            } else {
                characters.append(contentsOf: page.characters)
            }

            totalPages = page.info.totalPages
            hasMorePages = page.info.hasNextPage

            if characters.isEmpty {
                state = .empty
            } else {
                state = .loaded(characters)
            }
        } catch let error as NetworkError {
            if case .notFound = error {
                characters = []
                state = .empty
            } else {
                // Try to load cached data
                let cached = await getCachedCharactersUseCase.execute()
                if !cached.isEmpty, reset {
                    characters = cached
                    state = .loaded(cached)
                } else {
                    state = .error(error.localizedDescription)
                }
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private func loadMoreCharacters() async {
        guard !isLoadingMore, currentPage < totalPages else { return }

        isLoadingMore = true
        currentPage += 1

        do {
            let page = try await getCharactersUseCase.execute(
                page: currentPage,
                filter: currentFilter
            )

            characters.append(contentsOf: page.characters)
            hasMorePages = page.info.hasNextPage
            state = .loaded(characters)
        } catch {
            currentPage -= 1
        }

        isLoadingMore = false
    }

    // MARK: - Favorite Notification Observer

    func handleFavoriteStatusChanged(characterId: Int, isFavorite: Bool, character _: Character?) {
        updateCharacterFavorite(id: characterId, isFavorite: isFavorite)
    }

    func handleFavoritesListUpdated() {
        Task {
            await refresh()
        }
    }
}
