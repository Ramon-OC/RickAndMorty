//
//  CheckBiometricAvailability.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// protocol
protocol CheckBiometricAvailabilityProtocol {
    func execute() -> BiometricAvailability
}

// use case implementation
final class CheckBiometricAvailability: CheckBiometricAvailabilityProtocol {
    private let repository: BiometricAuthRepository

    init(repository: BiometricAuthRepository) {
        self.repository = repository
    }

    func execute() -> BiometricAvailability {
        let isAvailable = repository.canAuthenticateWithBiometrics()
        let biometricType = repository.getBiometricType()

        return BiometricAvailability(
            isAvailable: isAvailable,
            biometricType: biometricType
        )
    }
}
