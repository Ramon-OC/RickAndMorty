//
//  BiometricAvailability.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

struct BiometricAvailability {
    let isAvailable: Bool
    let biometricType: BiometricType

    var canAuthenticate: Bool {
        return isAvailable && biometricType != .none
    }
}
