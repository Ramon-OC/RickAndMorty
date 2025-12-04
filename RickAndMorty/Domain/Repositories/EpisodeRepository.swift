//
//  EpisodeRepository.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

protocol EpisodeRepository {
    func getEpisodes(ids: [Int]) async throws -> [Episode]
    func getEpisode(id: Int) async throws -> Episode
    func markEpisodeAsWatched(episodeId: Int, characterId: Int) async throws
    func unmarkEpisodeAsWatched(episodeId: Int, characterId: Int) async throws
    func getWatchedEpisodeIds(forCharacterId characterId: Int) async -> Set<Int>
}
