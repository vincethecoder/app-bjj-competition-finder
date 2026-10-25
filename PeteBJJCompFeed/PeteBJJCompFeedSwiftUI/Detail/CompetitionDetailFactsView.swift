//
//  CompetitionDetailFactsView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import SwiftUI

/// One row per fact the event has, skipping the ones it doesn't.
struct CompetitionDetailFactsView: View {
    let card: PosterCard

    var body: some View {
        if let dateText = card.dateText {
            LabeledContent {
                Text(dateText)
            } label: {
                Text(.detailDates)
            }
        }

        if let venue = card.details?.venue {
            LabeledContent {
                Text(venue)
            } label: {
                Text(.detailVenue)
            }
        }

        if let locationText = card.locationText {
            LabeledContent {
                Text(locationText)
            } label: {
                Text(.detailLocation)
            }
        }

        if let divisionsText = card.details?.divisionsText {
            LabeledContent {
                Text(divisionsText)
            } label: {
                Text(.detailDivisions)
            }
        }

        if let rankingPoints = card.details?.rankingPoints {
            LabeledContent {
                Text(rankingPoints, format: .number)
            } label: {
                Text(.detailRankingPoints)
            }
        }
    }
}
