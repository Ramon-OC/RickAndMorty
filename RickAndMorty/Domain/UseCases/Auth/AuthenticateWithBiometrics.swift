//
//  AuthenticateWithBiometrics.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

// protocol
protocol AuthenticateWithBiometricsProtocol {
    func execute(reason: String) async -> Result<Bool, BiometricAuthError>
}

// use case implementation
final class AuthenticateWithBiometrics: AuthenticateWithBiometricsProtocol {
    private let repository: BiometricAuthRepository

    init(repository: BiometricAuthRepository) {
        self.repository = repository
    }

    func execute(reason: String) async -> Result<Bool, BiometricAuthError> {
        // Validate input
        guard !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure(.invalidContext)
        }

        // Check availability before attempting authentication
        guard repository.canAuthenticateWithBiometrics() else {
            return .failure(.notAvailable)
        }

        // Perform authentication
        return await repository.authenticate(reason: reason)
    }
}
