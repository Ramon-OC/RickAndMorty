//
//  ViewState.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case empty
    case error(String)

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var data: T? {
        if case let .loaded(data) = self { return data }
        return nil
    }

    var errorMessage: String? {
        if case let .error(message) = self { return message }
        return nil
    }

    var isEmpty: Bool {
        if case .empty = self { return true }
        return false
    }
}
