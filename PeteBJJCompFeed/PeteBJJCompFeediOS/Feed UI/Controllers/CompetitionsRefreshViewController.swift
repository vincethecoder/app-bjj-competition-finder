//
//  CompetitionsRefreshViewController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/4/24.
//

import UIKit

protocol CompetitionsRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class CompetitionsRefreshViewController: NSObject, CompetitionsLoadingView {
    private(set) lazy var view =  loadView()
    
    private let delegate: CompetitionsRefreshViewControllerDelegate

    init(delegate: CompetitionsRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: CompetitionsLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
