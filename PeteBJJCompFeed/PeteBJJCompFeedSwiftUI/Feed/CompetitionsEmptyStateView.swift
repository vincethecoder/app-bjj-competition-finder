//
//  CompetitionsEmptyStateView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

struct CompetitionsEmptyStateView: View {
    let isLoading: Bool

    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            ContentUnavailableView(
                FeedStrings.emptyTitle,
                systemImage: "figure.martial.arts",
                description: Text(FeedStrings.emptyDescription))
        }
    }
}
