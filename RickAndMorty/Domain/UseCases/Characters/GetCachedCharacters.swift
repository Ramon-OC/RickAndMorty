//
//  GetCachedCharacters.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// protocol
protocol GetCachedCharactersProtocol {
    func execute() async -> [Character]
}

// use case implementation
final class GetCachedCharacters: GetCachedCharactersProtocol {
    private let repository: CharacterRepository

    init(repository: CharacterRepository) {
        self.repository = repository
    }

    func execute() async -> [Character] {
        await repository.getCachedCharacters()
    }
}
