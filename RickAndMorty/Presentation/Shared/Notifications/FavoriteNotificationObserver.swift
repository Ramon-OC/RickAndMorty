//
//  FavoriteNotificationObserver.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 03/12/25.
//

import Combine
import Foundation

// protocol to listen favorites changues
protocol FavoriteNotificationObserver: ObservableObject {
    func handleFavoriteStatusChanged(characterId: Int, isFavorite: Bool, character: Character?) /// when favorite button is pressed
    func handleFavoritesListUpdated() /// updates the list when favorite pressed
}

// manage the notficiations for individual an general changues
extension FavoriteNotificationObserver {
    // sets the observer [form init of the view model]
    func setupFavoriteNotifications() -> Set<AnyCancellable> {
        var cancellables = Set<AnyCancellable>()

        NotificationCenter.default // individual update
            .publisher(for: FavoriteNotificationManager.Notifications.favoriteStatusChanged)
            .sink { [weak self] notification in
                self?.processFavoriteStatusNotification(notification)
            }
            .store(in: &cancellables)

        NotificationCenter.default // list needs to be updated
            .publisher(for: FavoriteNotificationManager.Notifications.favoritesListUpdated)
            .sink { [weak self] _ in
                self?.handleFavoritesListUpdated()
            }
            .store(in: &cancellables)

        return cancellables
    }

    private func processFavoriteStatusNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let characterId = userInfo[FavoriteNotificationManager.UserInfoKeys.characterId] as? Int,
              let isFavorite = userInfo[FavoriteNotificationManager.UserInfoKeys.isFavorite] as? Bool
        else {
            return
        }

        let character = userInfo[FavoriteNotificationManager.UserInfoKeys.character] as? Character

        DispatchQueue.main.async {
            self.handleFavoriteStatusChanged(
                characterId: characterId,
                isFavorite: isFavorite,
                character: character
            )
        }
    }
}
