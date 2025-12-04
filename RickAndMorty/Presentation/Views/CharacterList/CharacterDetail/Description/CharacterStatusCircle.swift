//
//  CharacterStatusCircle.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 02/12/25.
//

import SwiftUI

struct CharacterStatusCircle: View {
    let status: CharacterStatus

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            Text(status.displayName)
                .foregroundColor(.white.opacity(0.9))
        }
    }

    private var statusColor: Color {
        switch status {
        case .alive: return .green
        case .dead: return .red
        case .unknown: return .yellow
        }
    }
}
