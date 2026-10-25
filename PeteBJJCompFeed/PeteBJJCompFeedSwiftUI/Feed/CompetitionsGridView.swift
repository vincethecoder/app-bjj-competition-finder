//
//  CompetitionsGridView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// The competitions feed: filter chips over a grid of event posters,
/// grouped and ordered by the server, with loading, empty and error states.
public struct CompetitionsGridView: View {
    public let viewModel: CompetitionsGridViewModel

    public init(viewModel: CompetitionsGridViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FeedDesign.gridSpacing) {
                    if let filters = viewModel.screen?.filters, !filters.isEmpty {
                        FilterChipsView(filters: filters, selectedID: viewModel.selectedFilterID, select: viewModel.selectFilter)
                    }

                    PosterGridView(sections: viewModel.visibleSections)
                }
                .padding(.bottom, FeedDesign.screenInset)
            }
            .background(Color(.feedBackground))
            .overlay {
                if viewModel.visibleSections.isEmpty {
                    // Let drags reach the scroll view underneath, so pull to refresh works.
                    CompetitionsEmptyStateView(
                        isLoading: viewModel.state == .loading(screen: nil),
                        title: emptyTitle,
                        message: emptyMessage)
                    .allowsHitTesting(false)
                }
            }
            .safeAreaInset(edge: .top) {
                if let message = viewModel.errorMessage {
                    ErrorBannerView(message: message, dismiss: viewModel.dismissError)
                }
            }
            // The app's own title shows until a screen has loaded.
            .navigationTitle(viewModel.screen.map { Text($0.title) } ?? Text(.feedViewTitle))
            .task { await load() }
            .refreshable { await load() }
        }
    }

    // A filter that hides every event gets the app's own copy; a screen with
    // no events at all keeps the server's.
    private var emptyTitle: Text {
        if viewModel.isFilteredToNothing { return Text(.feedFilterEmptyTitle) }
        return viewModel.screen.map { Text($0.emptyTitle) } ?? Text(.feedViewEmptyTitle)
    }

    private var emptyMessage: Text {
        if viewModel.isFilteredToNothing { return Text(.feedFilterEmptyDescription) }
        return viewModel.screen.map { Text($0.emptyMessage) } ?? Text(.feedViewEmptyDescription)
    }

    private func load() async {
        await viewModel.load()
    }
}

#if DEBUG
#Preview("Loaded") {
    CompetitionsGridView(viewModel: CompetitionsGridViewModel(loader: PreviewCompetitionsFeedLoader(.loaded)))
}

#Preview("Filtered, no matches") {
    CompetitionsGridView(viewModel: CompetitionsGridViewModel(loader: PreviewCompetitionsFeedLoader(.filteredEmpty)))
}

#Preview("Offline") {
    CompetitionsGridView(viewModel: CompetitionsGridViewModel(loader: PreviewCompetitionsFeedLoader(.offline)))
}

#Preview("Artwork fails to load") {
    CompetitionsGridView(viewModel: CompetitionsGridViewModel(loader: PreviewCompetitionsFeedLoader(.imageFailed)))
}
#endif
