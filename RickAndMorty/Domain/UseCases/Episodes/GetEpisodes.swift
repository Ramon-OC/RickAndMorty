//
//  GetEpisodes.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// Protocol
protocol GetEpisodesProtocol {
    func execute(ids: [Int], characterId: Int) async throws -> [Episode]
}

// Use case implementation
final class GetEpisodes: GetEpisodesProtocol {
    private let repository: EpisodeRepository

    init(repository: EpisodeRepository) {
        self.repository = repository
    }

    func execute(ids: [Int], characterId: Int) async throws -> [Episode] {
        var episodes = try await repository.getEpisodes(ids: ids)
        let watchedIds = await repository.getWatchedEpisodeIds(forCharacterId: characterId)

        episodes = episodes.map { episode in
            var mutableEpisode = episode
            mutableEpisode.isWatched = watchedIds.contains(episode.id)
            return mutableEpisode
        }

        return episodes.sorted { $0.id < $1.id }
    }
}
