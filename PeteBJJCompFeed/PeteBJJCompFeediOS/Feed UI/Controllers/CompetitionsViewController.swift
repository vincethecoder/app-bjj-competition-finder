//
//  CompetitionsViewController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/1/24.
//

import UIKit
import PeteBJJCompFeed

public final class CompetitionsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: CompetitionsRefreshViewController?
    private var imageLoader: EventImageDataLoader?
    private var onViewIsAppearing: ((CompetitionsViewController) -> Void)?
    private var tableModel = [Competition]() {
        didSet { tableView.reloadData() }
    }
    private var cellControllers = [IndexPath: CompetitionsCellController]()
    
    public convenience init(competitionLoader: CompetitionsLoader, imageLoader: EventImageDataLoader) {
        self.init()
        self.refreshController = CompetitionsRefreshViewController(competitionLoader: competitionLoader)
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
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
        refreshControl = refreshController?.view
        refreshController?.onRefresh = { [weak self] competition in
            self?.tableModel = competition
        }
        tableView.prefetchDataSource = self
        refreshController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> CompetitionsCellController {
        let cellModel = tableModel[indexPath.row]
        let cellController = CompetitionsCellController(model: cellModel, imageLoader: imageLoader!)
        cellControllers[indexPath] = cellController
        return cellController
    }
    
    private func removeCellController(forRowAt indexPath: IndexPath) {
        cellControllers[indexPath] = nil
    }
}
