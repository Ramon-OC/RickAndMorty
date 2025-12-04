//
//  CharacterRepositoryImpl.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import CoreData
import Foundation

// MARK: Character Repository Implementation

final class CharacterRepositoryImpl: CharacterRepository {
    private let networkClient: NetworkClientProtocol
    let coreDataStack: CoreDataStack

    init(
        networkClient: NetworkClientProtocol = NetworkClient.shared,
        coreDataStack: CoreDataStack = .shared
    ) {
        self.networkClient = networkClient
        self.coreDataStack = coreDataStack
    }

    func getCharacters(page: Int, filter: CharacterFilter?) async throws -> CharacterPage {
        let response: CharacterResponseDTO = try await networkClient.request(
            .characters(page: page, filters: filter)
        )

        let characters = response.results.map { $0.toDomain() }

        await cacheCharacters(characters)

        // Get favorites and merge
        let favoriteIds = await getFavoriteIds()
        let mergedCharacters = characters.map { character in
            var mutableChar = character
            mutableChar.isFavorite = favoriteIds.contains(character.id)
            return mutableChar
        }

        return CharacterPage(
            characters: mergedCharacters,
            info: PageInfo(
                totalCount: response.info.count,
                totalPages: response.info.pages,
                hasNextPage: response.info.next != nil,
                hasPreviousPage: response.info.prev != nil
            )
        )
    }

    func getCharacter(id: Int) async throws -> Character {
        let dto: CharacterDTO = try await networkClient.request(.character(id: id))
        var character = dto.toDomain()

        // Check if favorite
        let isFavorite = await isCharacterFavorite(id: id)
        character.isFavorite = isFavorite

        return character
    }

    func getCachedCharacters() async -> [Character] {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
                request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]

                do {
                    let entities = try context.fetch(request)
                    let characters = entities.map { $0.toDomain() }
                    continuation.resume(returning: characters)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    func toggleFavorite(characterId: Int) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
                request.predicate = NSPredicate(format: "id == %d", characterId)

                do {
                    let results = try context.fetch(request)
                    if let entity = results.first {
                        entity.isFavorite.toggle()
                        try context.save()
                    }
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // private Helpers
    private func cacheCharacters(_ characters: [Character]) async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                for character in characters {
                    let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
                    request.predicate = NSPredicate(format: "id == %d", character.id)

                    do {
                        let results = try context.fetch(request)
                        let entity: CharacterEntity

                        if let existing = results.first {
                            entity = existing
                        } else {
                            entity = CharacterEntity(context: context)
                        }

                        entity.update(from: character)

                    } catch {
                        print("Error caching character: \(error)")
                    }
                }

                do {
                    try context.save()
                } catch {
                    print("Error saving context: \(error)")
                }

                continuation.resume()
            }
        }
    }

    private func getFavoriteIds() async -> Set<Int> {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
                request.predicate = NSPredicate(format: "isFavorite == YES")

                do {
                    let results = try context.fetch(request)
                    let ids = Set(results.map { Int($0.id) })
                    continuation.resume(returning: ids)
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func isCharacterFavorite(id: Int) async -> Bool {
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
                request.predicate = NSPredicate(format: "id == %d AND isFavorite == YES", id)

                do {
                    let count = try context.count(for: request)
                    continuation.resume(returning: count > 0)
                } catch {
                    continuation.resume(returning: false)
                }
            }
        }
    }
}
