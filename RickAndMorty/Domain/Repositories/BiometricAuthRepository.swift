//
//  BiometricAuthRepository.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

protocol BiometricAuthRepository {
    func canAuthenticateWithBiometrics() -> Bool
    func authenticate(reason: String) async -> Result<Bool, BiometricAuthError>
    func getBiometricType() -> BiometricType
    func invalidateAuthentication()
}
