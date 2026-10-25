//
//  CompetitionDetailHeaderView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import SwiftUI

/// The poster with its badges, then the event's full name, which the card
/// may have cut short.
struct CompetitionDetailHeaderView: View {
    let card: PosterCard

    /// Grows with the text size, so large badges don't cover the whole poster.
    @ScaledMetric private var posterMaxWidth = FeedDesign.detailPosterMaxWidth

    var body: some View {
        VStack(spacing: FeedDesign.gridSpacing) {
            PosterArtworkView(card: card)
                // A full-width poster would fill an iPad screen on its own.
                .frame(maxWidth: posterMaxWidth)

            Text(card.name)
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
                // The poster takes all the height it's offered; the name keeps
                // the height it needs instead of truncating.
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, FeedDesign.cardPadding)
    }
}
