//
//  CompetitionsRefreshViewController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/4/24.
//

import UIKit
import PeteBJJCompFeed

final class CompetitionsRefreshViewController: NSObject {
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let competitionLoader: CompetitionsLoader
    
    init(competitionLoader: CompetitionsLoader) {
        self.competitionLoader = competitionLoader
    }
    
    var onRefresh: (([Competition]) -> Void)?
    
    @objc func refresh() {
        view.beginRefreshing()
        competitionLoader.load { [weak self] result in
            if let competition = try? result.get() {
                self?.onRefresh?(competition)
            }
            self?.view.endRefreshing()
        }
    }
}
