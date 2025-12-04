//
//  BiometricAuthRepositoryImpl.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Foundation
import LocalAuthentication

final class BiometricAuthRepositoryImpl: BiometricAuthRepository {
    // properties
    private var context: LAContext?
    private let contextQueue = DispatchQueue(label: "com.rickandmorty.biometric", qos: .userInitiated)

    // Public Methods
    func canAuthenticateWithBiometrics() -> Bool {
        let context = createContext()
        var error: NSError?
        let canAuthenticate = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)

        return canAuthenticate
    }

    func authenticate(reason: String) async -> Result<Bool, BiometricAuthError> {
        guard !reason.isEmpty else {
            return .failure(.invalidContext)
        }

        let context = createContext() // create new context
        self.context = context

        var error: NSError? // biometrics need to be available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .failure(mapNSErrorToBiometricError(error))
        }

        configureContext(context)

        do { // Perform authentication
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )

            return .success(success)

        } catch let error as LAError {
            return .failure(mapLAErrorToBiometricError(error))
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }

    func getBiometricType() -> BiometricType {
        let context = createContext()

        guard canAuthenticateWithBiometrics() else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .none:
            return .none
        case .opticID:
            return .none
        @unknown default:
            return .none
        }
    }

    func invalidateAuthentication() {
        contextQueue.sync {
            context?.invalidate()
            context = nil
        }
    }

    // Private Methods
    private func createContext() -> LAContext {
        let context = LAContext()
        return context
    }

    private func configureContext(_ context: LAContext) {
        context.touchIDAuthenticationAllowableReuseDuration = 0
        context.localizedCancelTitle = "Cancelar"
    }

    private func mapLAErrorToBiometricError(_ error: LAError) -> BiometricAuthError {
        switch error.code {
        case .authenticationFailed:
            return .authenticationFailed
        case .userCancel:
            return .userCancel
        case .userFallback:
            return .userCancel
        case .systemCancel:
            return .systemCancel
        case .passcodeNotSet:
            return .passcodeNotSet
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .biometryLockout:
            return .biometryLockout
        case .invalidContext:
            return .invalidContext
        case .appCancel:
            return .systemCancel
        case .notInteractive:
            return .invalidContext
        default:
            return .unknown(error.localizedDescription)
        }
    }

    private func mapNSErrorToBiometricError(_ error: NSError?) -> BiometricAuthError {
        guard let error = error else {
            return .notAvailable
        }

        if let laError = error as? LAError {
            return mapLAErrorToBiometricError(laError)
        }

        return .unknown(error.localizedDescription)
    }
}
