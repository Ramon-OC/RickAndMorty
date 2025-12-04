//
//  BiometricAuthenticationCoordinator.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class BiometricAuthenticationCoordinator: ObservableObject {
    @Published private(set) var authenticationState: AuthenticationState = .unauthenticated
    @Published private(set) var sessionExpirationDate: Date?

    private let repository: BiometricAuthRepository
    private let authenticateUseCase: AuthenticateWithBiometricsProtocol
    private let sessionTimeout: TimeInterval = 300 // cinco minutos, pero se puede mvr

    private var sessionTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init(repository: BiometricAuthRepository, authenticateUseCase: AuthenticateWithBiometricsProtocol) {
        self.repository = repository
        self.authenticateUseCase = authenticateUseCase
        setupNotifications()
    }

    // MARK: - Authentication

    func authenticate(reason: String) async -> Result<Void, BiometricAuthError> {
        authenticationState = .authenticating

        let result = await authenticateUseCase.execute(reason: reason)

        switch result {
        case let .success(authenticated):
            if authenticated {
                startSession()
                authenticationState = .authenticated
                return .success(())
            } else {
                authenticationState = .failed
                return .failure(.authenticationFailed)
            }

        case let .failure(error):
            authenticationState = .failed
            return .failure(error)
        }
    }

    // MARK: - Session Management

    func startSession() {
        let expirationDate = Date().addingTimeInterval(sessionTimeout)
        sessionExpirationDate = expirationDate
        scheduleSessionExpiration()
    }

    func invalidateSession() {
        sessionTimer?.invalidate()
        sessionTimer = nil
        sessionExpirationDate = nil
        authenticationState = .unauthenticated
        repository.invalidateAuthentication()
    }

    func extendSession() {
        guard authenticationState == .authenticated else { return }
        startSession()
    }

    // MARK: - Private Methods

    private func scheduleSessionExpiration() {
        sessionTimer?.invalidate()
        sessionTimer = Timer.scheduledTimer(
            withTimeInterval: sessionTimeout,
            repeats: false
        ) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleSessionExpiration()
            }
        }
    }

    private func handleSessionExpiration() {
        invalidateSession()
    }

    private func setupNotifications() {
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.invalidateSession()
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.invalidateSession()
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - Authentication States

enum AuthenticationState: Equatable {
    case unauthenticated
    case authenticating
    case authenticated
    case failed

    var isAuthenticated: Bool { return self == .authenticated }
}
