//
//  Episode.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

struct Episode: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let airDate: String
    let episodeCode: String
    let url: String
    var isWatched: Bool = false

    // Parse string from "S01E01" to Season 1, Episode 1
    var seasonNumber: Int? {
        guard let range = episodeCode.range(of: "S(\\d+)", options: .regularExpression),
              let number = Int(episodeCode[range].dropFirst()) else { return nil }
        return number
    }

    var episodeNumber: Int? {
        guard let range = episodeCode.range(of: "E(\\d+)", options: .regularExpression),
              let number = Int(episodeCode[range].dropFirst()) else { return nil }
        return number
    }

    var formattedCode: String {
        episodeCode
    }
}
