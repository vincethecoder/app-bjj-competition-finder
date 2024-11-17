//
//  CompetitionsCellController.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/5/24.
//

import UIKit
import PeteBJJCompFeed

protocol EventImageCellControllerDelegate {
    func didRequestImage()
        func didCancelImageRequest()
}

final class CompetitionsCellController: CompetitionsImageView {
    private let delegate: EventImageCellControllerDelegate
    private var cell: CompetitionsCell?
    
    init(delegate: EventImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(in tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompetitionsCell") as! CompetitionsCell
        self.cell = cell
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: CompetitionsImageViewModel<UIImage>) {
        cell?.dateLabel.text = viewModel.date
        cell?.dateLabel.text = viewModel.date
        cell?.eventLabel.text = viewModel.name
        cell?.venueLabel.text = viewModel.venue
        cell?.eventImageView?.image = viewModel.image
        cell?.eventImageContainer?.isShimmering = viewModel.isLoading
        cell?.eventImageRetryButton?.isHidden = !viewModel.shouldRetry
        cell?.onRetry = delegate.didRequestImage
    }
    
    func releaseCellForReuse() {
        cell = nil
    }
}
