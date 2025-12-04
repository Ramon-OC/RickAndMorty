//
//  LocationDTO+Mapping.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

extension LocationDTO {
    func toDomain() -> CharacterLocation {
        CharacterLocation(name: name, url: url)
    }
}
