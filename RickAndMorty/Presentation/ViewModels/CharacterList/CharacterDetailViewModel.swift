//
//  CharacterDetailViewModel.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class CharacterDetailViewModel: ObservableObject {
    @Published private(set) var character: Character
    @Published private(set) var episodes: [Episode] = []
    @Published private(set) var episodesState: ViewState<[Episode]> = .idle
    @Published private(set) var isTogglingFavorite = false
    @Published var showingRemoveFavoriteAlert = false

    private let getEpisodesUseCase: GetEpisodesProtocol
    private let toggleFavoriteUseCase: ToggleFavoriteProtocol
    private let toggleEpisodeWatchedUseCase: ToggleEpisodeWatchedProtocol

    var onFavoriteChanged: ((Int, Bool) -> Void)?

    // MARK: Computed Properties

    var watchedEpisodesCount: Int { episodes.filter { $0.isWatched }.count }
    var totalEpisodesCount: Int { episodes.count }
    var watchedProgress: Double {
        guard totalEpisodesCount > 0 else { return 0 }
        return Double(watchedEpisodesCount) / Double(totalEpisodesCount)
    }

    init(character: Character, getEpisodesUseCase: GetEpisodesProtocol, toggleFavoriteUseCase: ToggleFavoriteProtocol, toggleEpisodeWatchedUseCase: ToggleEpisodeWatchedProtocol) {
        self.character = character
        self.getEpisodesUseCase = getEpisodesUseCase
        self.toggleFavoriteUseCase = toggleFavoriteUseCase
        self.toggleEpisodeWatchedUseCase = toggleEpisodeWatchedUseCase
    }

    func getCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: character.coordinates.latitude,
            longitude: character.coordinates.longitude
        )
    }

    // MARK: Public Methods

    func loadEpisodes() async {
        guard case .idle = episodesState else { return }

        episodesState = .loading

        do {
            let episodeIds = character.episodeIds
            guard !episodeIds.isEmpty else {
                episodesState = .empty
                return
            }

            episodes = try await getEpisodesUseCase.execute(
                ids: episodeIds,
                characterId: character.id
            )

            if episodes.isEmpty {
                episodesState = .empty
            } else {
                episodesState = .loaded(episodes)
            }
        } catch {
            episodesState = .error(error.localizedDescription)
        }
    }

    func toggleFavorite() async {
        guard !isTogglingFavorite else { return }

        // Si está quitando favorito, mostrar confirmación
        if character.isFavorite {
            showingRemoveFavoriteAlert = true
            return
        }

        await performToggleFavorite()
    }

    func confirmRemoveFavorite() async {
        await performToggleFavorite()
    }

    private func performToggleFavorite() async {
        guard !isTogglingFavorite else { return }

        isTogglingFavorite = true

        do {
            try await toggleFavoriteUseCase.execute(characterId: character.id)
            character.isFavorite.toggle()
            objectWillChange.send()
            onFavoriteChanged?(character.id, character.isFavorite)
            FavoriteNotificationManager.shared.notifyFavoriteStatusChanged(
                characterId: character.id,
                isFavorite: character.isFavorite,
                character: character
            )
        } catch {
            // handle el error de aquí
        }

        isTogglingFavorite = false
    }

    func toggleEpisodeWatched(episode: Episode) async {
        do {
            try await toggleEpisodeWatchedUseCase.execute(
                episodeId: episode.id,
                characterId: character.id,
                isCurrentlyWatched: episode.isWatched
            )

            if let index = episodes.firstIndex(where: { $0.id == episode.id }) {
                episodes[index].isWatched.toggle()
                episodesState = .loaded(episodes)
            }
        } catch {
            // pendieENte: handle el error de aquí
        }
    }

    func markAllAsWatched() async {
        for episode in episodes where !episode.isWatched {
            await toggleEpisodeWatched(episode: episode)
        }
    }

    func markAllAsUnwatched() async {
        for episode in episodes where episode.isWatched {
            await toggleEpisodeWatched(episode: episode)
        }
    }
}
