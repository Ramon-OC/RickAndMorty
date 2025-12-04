//
//  CharacterResponseDTO.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

struct CharacterResponseDTO: Codable {
    let info: InfoDTO
    let results: [CharacterDTO]
}
