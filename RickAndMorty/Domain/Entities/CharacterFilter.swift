//
//  CharacterFilter.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

struct CharacterFilter: Equatable {
    var name: String?
    var status: CharacterStatus?
    var species: String?

    var isEmpty: Bool {
        name == nil && status == nil && species == nil
    }

    static var empty: CharacterFilter {
        CharacterFilter()
    }
}
