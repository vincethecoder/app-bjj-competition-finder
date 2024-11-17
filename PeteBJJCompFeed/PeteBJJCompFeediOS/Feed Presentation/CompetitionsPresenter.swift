//
//  CompetitionsPresenter.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/16/24.
//

import Foundation
import PeteBJJCompFeed

protocol CompetitionsLoadingView {
    func display(_ viewModel: CompetitionsLoadingViewModel)
}

protocol CompetitionsView {
    func display(_ viewModel: CompetitionsViewModel)
}

final class CompetitionsPresenter {
    private let competitionsView: CompetitionsView
    private let loadingView: CompetitionsLoadingView
    
    init(competitionsView: CompetitionsView, loadingView: CompetitionsLoadingView) {
        self.competitionsView = competitionsView
        self.loadingView = loadingView
    }
    
    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: CompetitionsPresenter.self),
                          comment: "Title for the feed view")
    }
    
    func didStartLoadingFeed() {
        loadingView.display(CompetitionsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with competitions: [Competition]) {
        competitionsView.display(CompetitionsViewModel(competitions: competitions))
        loadingView.display(CompetitionsLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(CompetitionsLoadingViewModel(isLoading: false))
    }
}
