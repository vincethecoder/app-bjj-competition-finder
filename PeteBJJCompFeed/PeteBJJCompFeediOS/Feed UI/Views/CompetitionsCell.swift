//
//  CompetitionsCell.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/3/24.
//

import UIKit

public final class CompetitionsCell: UITableViewCell {
    @IBOutlet private(set) public var dateLabel: UILabel!
    @IBOutlet private(set) public var eventLabel: UILabel!
    @IBOutlet private(set) public var venueLabel: UILabel!
    @IBOutlet private(set) public var eventImageContainer: UIView!
    @IBOutlet private(set) public var eventImageView: UIImageView!
    @IBOutlet private(set) public var eventImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
