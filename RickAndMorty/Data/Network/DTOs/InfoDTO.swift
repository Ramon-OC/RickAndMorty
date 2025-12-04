//
//  InfoDTO.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

struct InfoDTO: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}
