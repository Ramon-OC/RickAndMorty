//
//  BiometricAuthError.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation

enum BiometricAuthError: Error, Equatable {
    case notAvailable
    case notEnrolled
    case authenticationFailed
    case userCancel
    case systemCancel
    case passcodeNotSet
    case biometryLockout
    case invalidContext
    case timeout
    case unknown(String)

    var errorDescription: String {
        switch self {
        case .notAvailable:
            return "La autenticación biométrica no está disponible en este dispositivo"
        case .notEnrolled:
            return "No hay datos biométricos registrados. Configura Face ID o Touch ID en Ajustes"
        case .authenticationFailed:
            return "La autenticación falló. Por favor, intenta de nuevo"
        case .userCancel:
            return "Autenticación cancelada por el usuario"
        case .systemCancel:
            return "Autenticación cancelada por el sistema"
        case .passcodeNotSet:
            return "Debes configurar un código de acceso en tu dispositivo"
        case .biometryLockout:
            return "Biometría bloqueada por múltiples intentos fallidos. Usa tu código de acceso"
        case .invalidContext:
            return "Contexto de autenticación inválido"
        case .timeout:
            return "Tiempo de autenticación agotado"
        case let .unknown(message):
            return "Error desconocido: \(message)"
        }
    }

    var isRecoverable: Bool {
        switch self {
        case .userCancel, .authenticationFailed, .timeout:
            return true
        case .notAvailable, .notEnrolled, .passcodeNotSet, .biometryLockout, .systemCancel, .invalidContext, .unknown:
            return false
        }
    }
}
