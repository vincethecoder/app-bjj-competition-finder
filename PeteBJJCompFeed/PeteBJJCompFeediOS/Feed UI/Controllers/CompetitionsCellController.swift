//
//  CompetitionsCellController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/5/24.
//

import UIKit
import PeteBJJCompFeed

final class CompetitionsCellController {
    private let viewModel: CompetitionsImageViewModel
    
    init(viewModel: CompetitionsImageViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(CompetitionsCell())
        viewModel.loadImageData()
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: CompetitionsCell) -> CompetitionsCell {
        cell.dateLabel.text = viewModel.date
        cell.eventLabel.text = viewModel.name
        cell.venueLabel.text = viewModel.venue
        cell.eventImageView.image = nil
        cell.onRetry = viewModel.loadImageData
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.eventImageView.image = image
        }
        
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.eventImageContainer.isShimmering = isLoading
        }
        
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.eventImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
}
