//
//  BiometricLockView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct BiometricLockView: View {
    let biometricAvailability: BiometricAvailability
    let onAuthenticate: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            lockIcon
            titleSection

            Spacer()

            if biometricAvailability.canAuthenticate {
                authenticateButton
            } else {
                unavailableMessage
            }

            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    private var lockIcon: some View {
        Image(systemName: biometricAvailability.biometricType.icon)
            .font(.system(size: 80))
            .foregroundColor(.blue)
            .symbolRenderingMode(.hierarchical)
    }

    private var titleSection: some View {
        VStack(spacing: 12) {
            Text("Lista de Favoritos")
                .font(.title)
                .fontWeight(.bold)

            Text(biometricAvailability.canAuthenticate
                ? "Usa \(biometricAvailability.biometricType.displayName) para acceder a tus personajes favoritos"
                : "La autenticación no está disponible en este dispositivo")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var authenticateButton: some View {
        Button(action: onAuthenticate) {
            HStack(spacing: 12) {
                Image(systemName: biometricAvailability.biometricType.icon)
                Text("Autenticar con \(biometricAvailability.biometricType.displayName)") // will change based on the phone bio hardware
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .cornerRadius(12)
        }
    }

    private var unavailableMessage: some View {
        Text("Habilita Face ID en configuración para usar esta función")
            .font(.footnote)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
    }
}

#Preview("Face ID") {
    BiometricLockView(
        biometricAvailability: BiometricAvailability(
            isAvailable: true,
            biometricType: .faceID
        ),
        onAuthenticate: {}
    )
}

#Preview("Not Available") {
    BiometricLockView(
        biometricAvailability: BiometricAvailability(
            isAvailable: false,
            biometricType: .none
        ),
        onAuthenticate: {}
    )
}
