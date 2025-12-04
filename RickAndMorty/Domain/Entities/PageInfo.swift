//
//  PageInfo.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

struct PageInfo {
    let totalCount: Int
    let totalPages: Int
    let hasNextPage: Bool
    let hasPreviousPage: Bool
}

struct CharacterPage {
    let characters: [Character]
    let info: PageInfo
}
