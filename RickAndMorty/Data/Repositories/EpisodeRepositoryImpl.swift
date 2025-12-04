//
//  EpisodeRepositoryImpl.swift
//  RickAndMorty
//

import CoreData
import Foundation

final class EpisodeRepositoryImpl: EpisodeRepository {
    private let networkClient: NetworkClientProtocol
    private let coreDataStack: CoreDataStack

    init(networkClient: NetworkClientProtocol = NetworkClient.shared, coreDataStack: CoreDataStack = .shared) {
        self.networkClient = networkClient
        self.coreDataStack = coreDataStack
    }

    func getEpisodes(ids: [Int]) async throws -> [Episode] {
        guard !ids.isEmpty else { return [] }

        if ids.count == 1 {
            let dto: EpisodeDTO = try await networkClient.request(.episodes(ids: ids))
            return [dto.toDomain()]
        } else {
            let dtos: [EpisodeDTO] = try await networkClient.request(.episodes(ids: ids))
            return dtos.map { $0.toDomain() }
        }
    }

    func getEpisode(id: Int) async throws -> Episode {
        let dto: EpisodeDTO = try await networkClient.request(.episode(id: id))
        return dto.toDomain()
    }

    func markEpisodeAsWatched(episodeId: Int, characterId _: Int) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<EpisodeWatchedEntity>(entityName: "EpisodeWatchedEntity")
                request.predicate = NSPredicate(format: "episodeId == %d", episodeId)

                do {
                    let results = try context.fetch(request)
                    if results.isEmpty {
                        let entity = EpisodeWatchedEntity(context: context)
                        entity.episodeId = Int64(episodeId)
                        entity.watchedDate = Date()
                        try context.save()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func unmarkEpisodeAsWatched(episodeId: Int, characterId _: Int) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<EpisodeWatchedEntity>(entityName: "EpisodeWatchedEntity")
                request.predicate = NSPredicate(format: "episodeId == %d", episodeId)

                do {
                    let results = try context.fetch(request)
                    for entity in results {
                        context.delete(entity)
                    }
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    func getWatchedEpisodeIds(forCharacterId _: Int) async -> Set<Int> {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<EpisodeWatchedEntity>(entityName: "EpisodeWatchedEntity")

                do {
                    let results = try context.fetch(request)
                    let ids = Set(results.map { Int($0.episodeId) })
                    continuation.resume(returning: ids)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
