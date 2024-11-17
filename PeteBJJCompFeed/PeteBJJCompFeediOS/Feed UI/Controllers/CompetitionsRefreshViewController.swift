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
    @IBOutlet private var view: UIRefreshControl?
    
    var delegate: CompetitionsRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: CompetitionsLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
