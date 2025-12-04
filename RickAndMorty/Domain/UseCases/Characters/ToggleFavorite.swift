//
//  ToggleFavorite.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// protocol
protocol ToggleFavoriteProtocol {
    func execute(characterId: Int) async throws
}

// use case implementation
final class ToggleFavorite: ToggleFavoriteProtocol {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(characterId: Int) async throws {
        try await repository.toggleFavorite(characterId: characterId)
    }
}
