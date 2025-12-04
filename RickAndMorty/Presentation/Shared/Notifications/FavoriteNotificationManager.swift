//
//  FavoriteNotificationManager.swift
//  RickAndMorty
//
//  Created by José Ramón Ortiz Castañeda on 02/12/25.
//

import Foundation

/// Handles favorite  notifications
final class FavoriteNotificationManager {
    static let shared = FavoriteNotificationManager()

    enum Notifications {
        static let favoriteStatusChanged = Notification.Name("FavoriteStatusChanged")
        static let favoritesListUpdated = Notification.Name("FavoritesListUpdated")
    }

    enum UserInfoKeys {
        static let characterId = "characterId"
        static let isFavorite = "isFavorite"
        static let character = "character"
    }

    /// Posts a favorite state change event
    func notifyFavoriteStatusChanged(characterId: Int, isFavorite: Bool, character: Character? = nil) {
        var userInfo: [String: Any] = [
            UserInfoKeys.characterId: characterId,
            UserInfoKeys.isFavorite: isFavorite,
        ]

        if let character = character {
            userInfo[UserInfoKeys.character] = character
        }

        NotificationCenter.default.post(
            name: Notifications.favoriteStatusChanged,
            object: nil,
            userInfo: userInfo
        )
    }

    /// Posts a full favorites list update event
    func notifyFavoritesListUpdated() {
        NotificationCenter.default.post(
            name: Notifications.favoritesListUpdated,
            object: nil
        )
    }
}

extension NotificationCenter {
    /// Adds observer for favorite state changes
    func addFavoriteStatusObserver(_ observer: Any, selector: Selector) {
        addObserver(
            observer,
            selector: selector,
            name: FavoriteNotificationManager.Notifications.favoriteStatusChanged,
            object: nil
        )
    }

    /// Adds observer for full favorites list updates
    func addFavoritesListObserver(_ observer: Any, selector: Selector) {
        addObserver(
            observer,
            selector: selector,
            name: FavoriteNotificationManager.Notifications.favoritesListUpdated,
            object: nil
        )
    }
}
