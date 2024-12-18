//
//  CompetitionsViewController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/1/24.
//

import UIKit

protocol CompetitionsViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class CompetitionsViewController: UITableViewController, UITableViewDataSourcePrefetching, CompetitionsLoadingView, CompetitionsErrorView {
    var delegate: CompetitionsViewControllerDelegate?
    
    @IBOutlet private(set) public var errorView: ErrorView?
    
    private var onViewIsAppearing: ((CompetitionsViewController) -> Void)?
    var tableModel = [CompetitionsCellController]() {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        onViewIsAppearing = { vc in
            vc.load()
            vc.onViewIsAppearing = nil
        }
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearing?(self)
    }
    
    @objc private func load() {
        refresh()
    }
    
    func display(_ viewModel: CompetitionsLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    func display(_ viewModel: CompetitionsErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellController)
    }

    private func cellController(forRowAt indexPath: IndexPath) -> CompetitionsCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellController(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
