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
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didStartLoadingFeed() }
        }

        loadingView.display(CompetitionsLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with competitions: [Competition]) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: competitions) }
        }
        
        competitionsView.display(CompetitionsViewModel(competitions: competitions))
        loadingView.display(CompetitionsLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { [weak self] in self?.didFinishLoadingFeed(with: error) }
        }
        
        loadingView.display(CompetitionsLoadingViewModel(isLoading: false))
    }
}
