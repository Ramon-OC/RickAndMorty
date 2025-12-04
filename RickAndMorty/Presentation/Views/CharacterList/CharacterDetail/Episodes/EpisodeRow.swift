//
//  EpisodeRow.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 02/12/25.
//

import SwiftUI

struct EpisodeRow: View {
    let episode: Episode
    let onToggleWatched: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(episode.episodeCode)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.backgroundBlocks)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.rickBlue)
                .clipShape(RoundedRectangle(cornerRadius: 6))

            // episode info (S1E1 and date)
            VStack(alignment: .leading, spacing: 2) {
                Text(episode.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Text(episode.airDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // watched button (checkmark turns green when pressed)
            Button(action: onToggleWatched) {
                Image(systemName: episode.isWatched ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(episode.isWatched ? .green : .gray)
            }
        }
        .padding(12)
        .background(Color(.backgroundBlocks))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
