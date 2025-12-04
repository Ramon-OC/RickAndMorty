//
//  CharacterDTO+Mapping.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

extension CharacterDTO {
    func toDomain() -> Character {
        Character(
            id: id,
            name: name,
            status: CharacterStatus(rawValue: status.lowercased()) ?? .unknown,
            species: species,
            type: type,
            gender: CharacterGender(rawValue: gender.lowercased()) ?? .unknown,
            origin: origin.toDomain(),
            location: location.toDomain(),
            imageURL: URL(string: image),
            episodeURLs: episode.compactMap { URL(string: $0) },
            coordinates: CharacterCoordinates.deterministicInSeattle(for: id)
        )
    }
}
