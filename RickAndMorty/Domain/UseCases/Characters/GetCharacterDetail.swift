//
//  GetCharacterDetail.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// protocol
protocol GetCharacterDetailProtocol {
    func execute(id: Int) async throws -> Character
}

// use case implementation
final class GetCharacterDetail: GetCharacterDetailProtocol {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> Character {
        try await repository.getCharacter(id: id)
    }
}
