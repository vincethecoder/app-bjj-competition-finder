//
//  PosterCardView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// One event: the poster, then name, dates and location. The whole card is a
/// single link, so VoiceOver reads it as one element that opens the event's details.
struct PosterCardView: View {
    let card: PosterCard
    let favorites: FavoriteCompetitions

    @Environment(\.pixelLength) private var pixelLength

    var body: some View {
        NavigationLink(value: card) {
            VStack(alignment: .leading, spacing: FeedDesign.cardPadding) {
                PosterArtworkView(card: card)
                    .overlay(alignment: .topTrailing) {
                        if favorites.contains(card.id) {
                            FavoriteMarkView()
                        }
                    }
                PosterCardDetailsView(card: card)
            }
            .padding(FeedDesign.cardPadding)
            .frame(maxWidth: .infinity, minHeight: FeedDesign.minimumTapTarget, maxHeight: .infinity, alignment: .top)
            .background {
                RoundedRectangle(cornerRadius: FeedDesign.cardCornerRadius)
                    .fill(Color(.cardBackground))
                    .stroke(Color(.cardBorder), lineWidth: pixelLength)
            }
            .contentShape(.rect(cornerRadius: FeedDesign.cardCornerRadius))
        }
        .buttonStyle(.plain)
        .contextMenu {
            FavoriteButton(id: card.id, favorites: favorites)
        }
        // VoiceOver users star an event from the Actions rotor.
        .accessibilityActions {
            FavoriteButton(id: card.id, favorites: favorites)
        }
        .accessibilityHint(Text(.feedCardShowDetailsHint))
        // The spoken label includes dates, location and badges; Voice Control
        // users only need to say the event's name.
        .accessibilityInputLabels([card.name])
    }
}
