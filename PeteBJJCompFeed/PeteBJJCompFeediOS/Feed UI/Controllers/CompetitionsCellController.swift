//
//  CompetitionsCellController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/5/24.
//

import UIKit
import PeteBJJCompFeed

final class CompetitionsCellController {
    private var task: EventImageDataLoaderTask?
    private let model: Competition
    private let imageLoader: EventImageDataLoader
    
    init(model: Competition, imageLoader: EventImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func view() -> UITableViewCell {
        let cell = CompetitionsCell()
        let event = model.toCompetitiveEvent()
        cell.dateLabel.text = event.date
        cell.eventLabel.text = event.name
        cell.venueLabel.text = event.venue
        cell.eventImageView.image = nil
        cell.eventImageRetryButton.isHidden = true
        cell.eventImageContainer.startShimmering()
        
        let loadImage = { [weak self, weak cell] in
            guard let self else { return }
            
            self.task = self.imageLoader.loadImageData(from: event.url) { [weak cell] result in
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
    
    func preload() {
        task = imageLoader.loadImageData(from: model.toCompetitiveEvent().url) { _ in }
    }
    
    func cancelLoad() {
        task?.cancel()
    }
}
