//
//  CharacterRepository.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

protocol CharacterRepository {
    func getCharacters(page: Int, filter: CharacterFilter?) async throws -> CharacterPage
    func getCharacter(id: Int) async throws -> Character
    func getCachedCharacters() async -> [Character]
    func getFavoriteCharacters() async -> [Character]
    func toggleFavorite(characterId: Int) async throws
}
