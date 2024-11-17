//
//  CompetitionsLoaderPresentationAdapter.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/17/24.
//

import PeteBJJCompFeed

final class CompetitionsLoaderPresentationAdapter: CompetitionsViewControllerDelegate {
    private let feedLoader: CompetitionsLoader
    var presenter: CompetitionsPresenter?

    init(feedLoader: CompetitionsLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)

            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
