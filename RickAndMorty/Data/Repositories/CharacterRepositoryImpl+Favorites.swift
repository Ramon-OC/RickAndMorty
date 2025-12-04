//
//  CharacterRepositoryImpl+Favorites.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import CoreData
import Foundation

extension CharacterRepositoryImpl {
    func getFavoriteCharacters() async -> [Character] { // get characters form core data [favorites]
        await withCheckedContinuation { continuation in
            let context = coreDataStack.viewContext
            context.perform {
                let request = NSFetchRequest<CharacterEntity>(entityName: "CharacterEntity")
                request.predicate = NSPredicate(format: "isFavorite == YES")
                request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

                do {
                    let entities = try context.fetch(request)
                    let characters = entities.map { $0.toDomain() }
                    continuation.resume(returning: characters)
                } catch { // error fetching characters
                    continuation.resume(returning: [])
                }
            }
        }
    }
}
