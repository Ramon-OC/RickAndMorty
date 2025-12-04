//
//  FavoriteCharacterRow.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct FavoriteCharacterRow: View {
    let character: Character
    let onRemoveFavorite: () -> Void
    @State private var showRemoveAlert = false

    var body: some View {
        HStack(spacing: 12) {
            characterImage
            characterInfo
            Spacer()
            favoriteButton
        }
        .padding(12)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .alert("Quitar de Favoritos", isPresented: $showRemoveAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Quitar", role: .destructive) {
                onRemoveFavorite()
            }
        } message: {
            Text("¿Estás seguro de que quieres quitar a \(character.name) de tus favoritos?")
        }
    }

    private var characterImage: some View {
        AsyncImage(url: character.imageURL) { phase in
            switch phase {
            case .empty:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        ProgressView()
                    }
            case let .success(image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    }
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var characterInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(character.name)
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(1)

            Text(character.species)
                .font(.subheadline)
                .foregroundColor(.secondary)

            HStack(spacing: 6) {
                Circle()
                    .fill(character.status.characterStatusColor)
                    .frame(width: 10, height: 10)

                Text(character.status.displayName)
                    .foregroundColor(.white.opacity(0.9))
            }
        }
    }

    private var favoriteButton: some View {
        Button(action: { showRemoveAlert = true }) {
            Image(systemName: "heart.fill")
                .font(.title3)
                .foregroundColor(.red)
        }
        .buttonStyle(.plain)
    }
}
