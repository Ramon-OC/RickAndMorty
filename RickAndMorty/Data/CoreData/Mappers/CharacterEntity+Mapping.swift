//
//  CharacterEntity+Mapping.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import CoreData
import Foundation

extension CharacterEntity {
    func toDomain() -> Character {
        let imageURLString = imageURL ?? ""
        let characterImageURL: URL? = imageURLString.isEmpty ? nil : URL(string: imageURLString)

        return Character(
            id: Int(id),
            name: name ?? "",
            status: CharacterStatus(rawValue: status ?? "") ?? .unknown,
            species: species ?? "",
            type: type ?? "",
            gender: CharacterGender(rawValue: gender ?? "") ?? .unknown,
            origin: CharacterLocation(name: originName ?? "", url: originURL ?? ""),
            location: CharacterLocation(name: locationName ?? "", url: locationURL ?? ""),
            imageURL: characterImageURL,
            episodeURLs: (episodeURLs ?? []).compactMap { URL(string: $0) },
            coordinates: CharacterCoordinates.deterministicInSeattle(for: Int(id)),
            isFavorite: isFavorite
        )
    }

    func update(from character: Character) {
        id = Int64(character.id)
        name = character.name
        status = character.status.rawValue
        species = character.species
        type = character.type
        gender = character.gender.rawValue
        originName = character.origin.name
        originURL = character.origin.url
        locationName = character.location.name
        locationURL = character.location.url
        imageURL = character.imageURL?.absoluteString
        episodeURLs = character.episodeURLs.map { $0.absoluteString }
        lastUpdated = Date()
    }
}
