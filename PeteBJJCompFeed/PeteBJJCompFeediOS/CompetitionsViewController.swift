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
    private var onViewIsAppearing: ((CompetitionsViewController) -> Void)?
    private var tableModel = [Competition]()
    
    public convenience init(loader: CompetitionsLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        onViewIsAppearing = { vc in
            vc.load()
            vc.onViewIsAppearing = nil
        }
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] result in
            switch result {
            case let .success(competitions):
                self?.tableModel = competitions
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()

            case .failure: break
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = tableModel[indexPath.row]
        let cell = CompetitionsCell()
        let event = cellModel.toCompetitiveEvent()
        cell.dateLabel.text = event.date
        cell.eventLabel.text = event.name
        cell.venueLabel.text = event.venue
        return cell
    }
}
