//
//  PosterCardDetailsView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// The text under a poster: one fact per line.
struct PosterCardDetailsView: View {
    let card: PosterCard

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        // At large text sizes the grid is one column wide, so lines can wrap
        // instead of truncating.
        let wrapsText = dynamicTypeSize >= FeedDesign.largeTextSize

        VStack(alignment: .leading) {
            Text(card.name)
                .font(.headline)
                .lineLimit(wrapsText ? nil : 2)

            if let dateText = card.dateText {
                Text(dateText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(wrapsText ? nil : 1)
            }

            if let locationText = card.locationText {
                Text(locationText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(wrapsText ? nil : 1)
            }
        }
        .multilineTextAlignment(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
