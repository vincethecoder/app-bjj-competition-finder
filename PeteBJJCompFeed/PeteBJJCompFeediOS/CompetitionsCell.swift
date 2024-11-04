//
//  CompetitionsCell.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/3/24.
//

import UIKit

public final class CompetitionsCell: UITableViewCell {
    public let dateLabel = UILabel()
    public let eventLabel = UILabel()
    public let venueLabel = UILabel()
    public let eventImageContainer = UIView()
    public let eventImageView = UIImageView()
    
    private(set) public lazy var eventImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
