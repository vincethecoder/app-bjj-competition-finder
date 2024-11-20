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

protocol CompetitionsErrorView {
    func display(_ viewModel: CompetitionsErrorViewModel)
}

final class CompetitionsPresenter {
    private let competitionsView: CompetitionsView
    private let loadingView: CompetitionsLoadingView
    private let errorView: CompetitionsErrorView
    
    init(competitionsView: CompetitionsView, loadingView: CompetitionsLoadingView, errorView: CompetitionsErrorView) {
        self.competitionsView = competitionsView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        NSLocalizedString("FEED_VIEW_TITLE",
                          tableName: "Feed",
                          bundle: Bundle(for: CompetitionsPresenter.self),
                          comment: "Title for the feed view")
    }
    
    private var competitionsLoadError: String {
        NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: CompetitionsPresenter.self),
                          comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(CompetitionsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with competitions: [Competition]) {
        competitionsView.display(CompetitionsViewModel(competitions: competitions))
        loadingView.display(CompetitionsLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: competitionsLoadError))
        loadingView.display(CompetitionsLoadingViewModel(isLoading: false))
    }
}
