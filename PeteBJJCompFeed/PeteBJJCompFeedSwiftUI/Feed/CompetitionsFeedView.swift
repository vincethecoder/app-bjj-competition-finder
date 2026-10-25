//
//  CompetitionsFeedView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// The competitions feed: a refreshable list with empty, loading and error states.
public struct CompetitionsFeedView: View {
    public let viewModel: CompetitionsListViewModel

    public init(viewModel: CompetitionsListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            List(viewModel.rows) { row in
                CompetitionRowView(row: row)
            }
            .overlay {
                if viewModel.rows.isEmpty {
                    // Let drags reach the list underneath, so pull to refresh works.
                    CompetitionsEmptyStateView(isLoading: viewModel.isLoading)
                        .allowsHitTesting(false)
                }
            }
            .safeAreaInset(edge: .top) {
                if let message = viewModel.errorMessage {
                    ErrorBannerView(message: message, dismiss: viewModel.dismissError)
                }
            }
            .navigationTitle(Text(.feedViewTitle))
            .task { await load() }
            .refreshable { await load() }
        }
    }

    private func load() async {
        await viewModel.load()
    }
}

#Preview("Loaded") {
    CompetitionsFeedView(viewModel: CompetitionsListViewModel(loader: PreviewCompetitionsLoader(result: .success(PreviewCompetitionsLoader.sampleCompetitions))))
}

#Preview("Empty") {
    CompetitionsFeedView(viewModel: CompetitionsListViewModel(loader: PreviewCompetitionsLoader(result: .success([]))))
}

#Preview("Error") {
    CompetitionsFeedView(viewModel: CompetitionsListViewModel(loader: PreviewCompetitionsLoader(result: .failure(PreviewCompetitionsLoader.PreviewError()))))
}
