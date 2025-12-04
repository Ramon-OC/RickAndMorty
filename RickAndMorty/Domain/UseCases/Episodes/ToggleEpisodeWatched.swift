//
//  ToggleEpisodeWatched.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// Protocol
protocol ToggleEpisodeWatchedProtocol {
    func execute(episodeId: Int, characterId: Int, isCurrentlyWatched: Bool) async throws
}

// Use case implementation
final class ToggleEpisodeWatched: ToggleEpisodeWatchedProtocol {
    private let repository: EpisodeRepository

    init(repository: EpisodeRepository) {
        self.repository = repository
    }

    func execute(episodeId: Int, characterId: Int, isCurrentlyWatched: Bool) async throws {
        if isCurrentlyWatched {
            try await repository.unmarkEpisodeAsWatched(episodeId: episodeId, characterId: characterId)
        } else {
            try await repository.markEpisodeAsWatched(episodeId: episodeId, characterId: characterId)
        }
    }
}
