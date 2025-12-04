//
//  InfoCard.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 02/12/25.
//

import SwiftUI

struct InfoCard: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.rickBlue)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }

            Spacer()
        }
        .padding(12)
        .background(Color(.backgroundBlocks))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(minHeight: 70, maxHeight: 70)
    }
}
