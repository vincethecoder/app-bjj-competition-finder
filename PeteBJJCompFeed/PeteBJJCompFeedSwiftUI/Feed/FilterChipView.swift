//
//  FilterChipView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

struct FilterChipView: View {
    let filter: PosterFilter
    let isSelected: Bool
    let select: @MainActor (PosterFilter.ID) -> Void

    @Environment(\.pixelLength) private var pixelLength

    var body: some View {
        Button(action: selectFilter) {
            Text(filter.title)
                .font(.subheadline)
                .bold()
                .lineLimit(1)
                .padding(.horizontal, FeedDesign.screenInset)
                .frame(minHeight: FeedDesign.minimumTapTarget)
                .foregroundStyle(isSelected ? Color.white : Color.primary)
                .background {
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.cardBackground))
                        .stroke(Color(.cardBorder), lineWidth: pixelLength)
                }
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private func selectFilter() {
        select(filter.id)
    }
}
