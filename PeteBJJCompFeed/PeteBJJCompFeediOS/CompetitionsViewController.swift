//
//  CompetitionsViewController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/1/24.
//

import UIKit
import PeteBJJCompFeed

final public class CompetitionsViewController: UITableViewController {
    private var loader: CompetitionsLoader?
    
    public convenience init(loader: CompetitionsLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
