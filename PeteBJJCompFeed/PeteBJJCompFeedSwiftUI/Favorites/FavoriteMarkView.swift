//
//  FavoriteMarkView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import SwiftUI

/// The star in the corner of a favorite event's poster.
struct FavoriteMarkView: View {
    var body: some View {
        Image(systemName: "star.fill")
            .font(.caption)
            .bold()
            .foregroundStyle(.yellow)
            .padding(FeedDesign.badgeSpacing)
            .background(.regularMaterial, in: .circle)
            .padding(FeedDesign.cardPadding)
            // Read as part of the card, after its name.
            .accessibilityLabel(Text(.feedCardFavorite))
    }
}
