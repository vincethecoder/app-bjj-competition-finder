//
//  FilterChipsView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// A horizontally scrolling row of filters with one selected.
struct FilterChipsView: View {
    let filters: [PosterFilter]
    let selectedID: PosterFilter.ID?
    let select: @MainActor (PosterFilter.ID) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: FeedDesign.chipSpacing) {
                ForEach(filters) { filter in
                    FilterChipView(filter: filter, isSelected: filter.id == selectedID, select: select)
                }
            }
            .padding(.horizontal, FeedDesign.screenInset)
        }
        .scrollIndicators(.hidden)
    }
}
