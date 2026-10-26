//
//  FavoriteButton.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import SwiftUI

/// Stars or unstars one event. Its title says what tapping does, so it reads
/// the same in a toolbar, a context menu and the VoiceOver actions rotor.
struct FavoriteButton: View {
    let id: String
    let favorites: FavoriteCompetitions

    var body: some View {
        let isFavorite = favorites.contains(id)

        Button(action: toggle) {
            Label {
                Text(isFavorite ? .favoriteRemove : .favoriteAdd)
            } icon: {
                Image(systemName: "star")
                    .symbolVariant(isFavorite ? .fill : .none)
            }
        }
    }

    private func toggle() {
        favorites.toggle(id)
    }
}
