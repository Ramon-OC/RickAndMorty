//
//  NetworkError.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "El URL no es valido"
        case .noData:
            return "No contiene datos"
        case let .decodingError(error):
            return "Error de decoding: \(error.localizedDescription)"
        case let .serverError(code):
            return "Error de servidor. Código: \(code)"
        case let .networkError(error):
            return "Error de red: \(error.localizedDescription)"
        case .notFound:
            return "Recurso no encontrado"
        }
    }
}
