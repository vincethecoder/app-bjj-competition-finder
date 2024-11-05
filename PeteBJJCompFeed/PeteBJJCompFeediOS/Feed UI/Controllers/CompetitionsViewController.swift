//
//  CompetitionsViewController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/1/24.
//

import UIKit
import PeteBJJCompFeed

public final class CompetitionsViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var competitionLoader: CompetitionsLoader?
    private var imageLoader: EventImageDataLoader?
    private var onViewIsAppearing: ((CompetitionsViewController) -> Void)?
    private var tableModel = [Competition]()
    private var tasks = [IndexPath: EventImageDataLoaderTask]()
    
    public convenience init(loader: CompetitionsLoader, imageLoader: EventImageDataLoader) {
        self.init()
        self.competitionLoader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        tableView.prefetchDataSource = self
        
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
        competitionLoader?.load { [weak self] result in
            if let competitions = try? result.get() {
                self?.tableModel = competitions
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing() 
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
        cell.eventImageView.image = nil
        cell.eventImageRetryButton.isHidden = true
        cell.eventImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: event.url) { [weak cell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell?.eventImageView.image = image
                cell?.eventImageRetryButton.isHidden = (image != nil)
                cell?.eventImageContainer.stopShimmering()
            }
        }
        
        cell.onRetry = loadImage
        loadImage()
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellModel = tableModel[indexPath.row]
            let event = cellModel.toCompetitiveEvent()
            tasks[indexPath] = imageLoader?.loadImageData(from: event.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
