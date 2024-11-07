//
//  CompetitionsRefreshViewController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/4/24.
//

import UIKit

final class CompetitionsRefreshViewController: NSObject {
    private(set) lazy var view =  binded(UIRefreshControl())
    
    private let viewModel: CompetitionsViewModel

    init(viewModel: CompetitionsViewModel) {
        self.viewModel = viewModel
    }
    
    @objc func refresh() {
        viewModel.loadCompetitions()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
