//
//  PosterGridView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// The sections and their poster cards, in server order.
struct PosterGridView: View {
    let sections: [PosterSection]

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        LazyVGrid(
            columns: GridColumns.items(count: GridColumns.count(horizontalSizeClass: horizontalSizeClass, dynamicTypeSize: dynamicTypeSize)),
            alignment: .leading,
            spacing: FeedDesign.gridSpacing
        ) {
            ForEach(sections) { section in
                Section {
                    ForEach(section.cards) { card in
                        PosterCardView(card: card)
                    }
                } header: {
                    PosterSectionHeaderView(title: section.title)
                }
            }
        }
        .padding(.horizontal, FeedDesign.screenInset)
    }
}
