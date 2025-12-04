//
//  GetCharacters.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// protocol
protocol GetCharactersProtocol {
    func execute(page: Int, filter: CharacterFilter?) async throws -> CharacterPage
}

// use case implementation
final class GetCharacters: GetCharactersProtocol {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute(page: Int, filter: CharacterFilter?) async throws -> CharacterPage {
        try await repository.getCharacters(page: page, filter: filter)
    }
}
