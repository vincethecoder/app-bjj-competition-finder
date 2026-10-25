//
//  PosterArtworkView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// The 3:4 poster, with the card's badges along the bottom. Missing or failed
/// artwork shows a placeholder, so the card still reads well without it.
struct PosterArtworkView: View {
    let card: PosterCard

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Color.clear
            .aspectRatio(FeedDesign.posterAspectRatio, contentMode: .fit)
            .overlay {
                if let imageURL = card.imageURL {
                    AsyncImage(url: imageURL, transaction: Transaction(animation: .default)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 1.05)))
                        } else {
                            PosterPlaceholderView(initial: card.initial)
                        }
                    }
                } else {
                    PosterPlaceholderView(initial: card.initial)
                }
            }
            .clipShape(.rect(cornerRadius: FeedDesign.posterCornerRadius))
            .accessibilityHidden(true)
            .overlay(alignment: .bottomLeading) {
                if !card.badges.isEmpty {
                    BadgeFlowLayout(spacing: FeedDesign.badgeSpacing) {
                        ForEach(card.badges) { badge in
                            BadgeCapsuleView(badge: badge)
                        }
                    }
                    .padding(FeedDesign.cardPadding)
                }
            }
    }
}
