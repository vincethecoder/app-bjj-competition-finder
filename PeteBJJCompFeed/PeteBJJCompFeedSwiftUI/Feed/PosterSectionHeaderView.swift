//
//  PosterSectionHeaderView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

struct PosterSectionHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title2)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, FeedDesign.gridSpacing)
            .accessibilityAddTraits(.isHeader)
    }
}
