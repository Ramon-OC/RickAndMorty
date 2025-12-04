//
//  Character.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

struct Character: Identifiable, Equatable, Hashable {
    let id: Int
    let name: String
    let status: CharacterStatus
    let species: String
    let type: String
    let gender: CharacterGender
    let origin: CharacterLocation
    let location: CharacterLocation
    let imageURL: URL?
    let episodeURLs: [URL]
    let coordinates: CharacterCoordinates
    var isFavorite: Bool = false

    var episodeIds: [Int] {
        episodeURLs.compactMap { url in
            guard let lastPathComponent = url.pathComponents.last,
                  let id = Int(lastPathComponent) else { return nil }
            return id
        }
    }

    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: Character Status

enum CharacterStatus: String, CaseIterable {
    case alive
    case dead
    case unknown

    var displayName: String {
        switch self {
        case .alive: return "Vivo"
        case .dead: return "Muerto"
        case .unknown: return "Desconocido"
        }
    }

    var color: String {
        switch self {
        case .alive: return "green"
        case .dead: return "red"
        case .unknown: return "gray"
        }
    }
}

// MARK: Character Gender

enum CharacterGender: String, CaseIterable {
    case male
    case female
    case genderless
    case unknown

    var displayName: String {
        switch self {
        case .male:
            "Masculino"
        case .female:
            "Femenino"
        case .genderless:
            "Sin Género"
        case .unknown:
            "Desconocido"
        }
    }
}

// MARK: Character Location

struct CharacterLocation: Equatable, Hashable {
    let name: String
    let url: String
}

// MARK: Character Coordinates

struct CharacterCoordinates: Equatable, Hashable, Codable {
    let latitude: Double
    let longitude: Double

    // Seattle coordinates
    static let seattleBounds = (
        minLatitude: 47.4814,
        maxLatitude: 47.7341,
        minLongitude: -122.4594,
        maxLongitude: -122.2244
    )

    // Generar coordenada determinista basándose en el id del personaje
    static func deterministicInSeattle(for id: Int) -> CharacterCoordinates {
        // Simple hash: mezcla el id para obtener dos valores entre 0 y 1
        func normalize(_ value: UInt64) -> Double {
            return Double(value % 1_000_000) / 999_999.0
        }
        // Usa id y una constante diferente para lat/lon para evitar correlación
        let latHash = UInt64(truncatingIfNeeded: id &* 6_364_136_223_846_793_005 &+ 1)
        let lngHash = UInt64(truncatingIfNeeded: (id &* 1_442_695_040_888_963_407) ^ 0x5BD1_E995)
        let latNorm = normalize(latHash)
        let lngNorm = normalize(lngHash)

        let lat = seattleBounds.minLatitude + latNorm * (seattleBounds.maxLatitude - seattleBounds.minLatitude)
        let lng = seattleBounds.minLongitude + lngNorm * (seattleBounds.maxLongitude - seattleBounds.minLongitude)

        return CharacterCoordinates(latitude: lat, longitude: lng)
    }
}
