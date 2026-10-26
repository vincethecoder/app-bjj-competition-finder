//
//  FeedRefineMenu.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import SwiftUI

/// Narrows the feed to a date range and a country, on top of the filter chips.
struct FeedRefineMenu: View {
    @Bindable var viewModel: CompetitionsGridViewModel

    var body: some View {
        Menu {
            Picker(selection: $viewModel.refinement.dateRange) {
                ForEach(PosterDateRange.allCases) { range in
                    Text(range.title)
                        .tag(range)
                }
            } label: {
                // Menus show a second text as the row's subtitle.
                Text(.feedRefineDate)
                Text(viewModel.refinement.dateRange.title)
            }
            .pickerStyle(.menu)

            // Picking from one country would hide nothing.
            if viewModel.countries.count > 1 {
                Picker(selection: $viewModel.refinement.country) {
                    Text(.feedRefineAnywhere)
                        .tag(String?.none)

                    ForEach(viewModel.countries, id: \.self) { country in
                        Text(country)
                            .tag(Optional(country))
                    }
                } label: {
                    Text(.feedRefineLocation)
                    Text(countryTitle)
                }
                .pickerStyle(.menu)
            }

            if viewModel.refinement.isActive {
                Button(action: reset) {
                    Label {
                        Text(.feedRefineReset)
                    } icon: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
            }
        } label: {
            Label {
                Text(.feedRefine)
            } icon: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .symbolVariant(viewModel.refinement.isActive ? .fill : .none)
            }
        }
        // The icon fills in when the feed is narrowed; VoiceOver reads what to.
        .accessibilityValue(summary)
    }

    private var countryTitle: String {
        viewModel.refinement.country ?? String(localized: .feedRefineAnywhere)
    }

    /// "This month, Brazil"
    private var summary: String {
        [String(localized: viewModel.refinement.dateRange.title), countryTitle].joined(separator: ", ")
    }

    private func reset() {
        viewModel.refinement = PosterRefinement()
    }
}
