//
//  CharacterRowView.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import SwiftUI

struct CharacterRowView: View {
    let character: Character
    @State private var isFavorite: Bool

    init(character: Character) {
        self.character = character
        _isFavorite = State(initialValue: character.isFavorite)
    }

    var body: some View {
        HStack(spacing: 12) {
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

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(character.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(character.species)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 6) {
                    Circle()
                        .fill(character.status.characterStatusColor)
                        .frame(width: 10, height: 10)

                    Text(character.status.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding(12)
        .background(Color(.backgroundBlocks))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .onReceive(NotificationCenter.default.publisher(for: FavoriteNotificationManager.Notifications.favoriteStatusChanged)) { notification in
            handleFavoriteNotification(notification)
        }
    }

    private func handleFavoriteNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let characterId = userInfo[FavoriteNotificationManager.UserInfoKeys.characterId] as? Int,
              let newFavoriteStatus = userInfo[FavoriteNotificationManager.UserInfoKeys.isFavorite] as? Bool,
              characterId == character.id
        else {
            return
        }

        withAnimation(.easeInOut(duration: 0.3)) {
            isFavorite = newFavoriteStatus
        }
    }
}
