//
//  APIEndpoint.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

enum APIEndpoint {
    case characters(page: Int, filters: CharacterFilter?)
    case character(id: Int)
    case episodes(ids: [Int])
    case episode(id: Int)

    var baseURL: String { "https://rickandmortyapi.com/api" }

    var path: String {
        switch self {
        case .characters:
            return "/character"
        case let .character(id):
            return "/character/\(id)"
        case let .episodes(ids):
            if ids.count == 1 {
                return "/episode/\(ids[0])"
            }
            return "/episode/\(ids.map(String.init).joined(separator: ","))"
        case let .episode(id):
            return "/episode/\(id)"
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case let .characters(page, filters):
            var items = [URLQueryItem(name: "page", value: String(page))]
            if let filters = filters {
                if let name = filters.name, !name.isEmpty {
                    items.append(URLQueryItem(name: "name", value: name))
                }
                if let status = filters.status {
                    items.append(URLQueryItem(name: "status", value: status.rawValue))
                }
                if let species = filters.species, !species.isEmpty {
                    items.append(URLQueryItem(name: "species", value: species))
                }
            }
            return items
        default:
            return nil
        }
    }

    var url: URL? {
        var components = URLComponents(string: baseURL + path)
        components?.queryItems = queryItems
        return components?.url
    }
}
