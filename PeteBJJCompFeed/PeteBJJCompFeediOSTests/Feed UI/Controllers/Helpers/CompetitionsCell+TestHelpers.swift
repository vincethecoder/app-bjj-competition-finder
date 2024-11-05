//
//  CompetitionsCell+TestHelpers.swift
//  PeteBJJCompFeediOSTests
//
//  Created by Kobe Sam on 11/4/24.
//

import UIKit
import PeteBJJCompFeediOS

extension CompetitionsCell {
    func simulateRetryAction() {
        eventImageRetryButton.simulateTap()
    }
    
    var isShowingImageLoadingIndicator: Bool {
        eventImageContainer.isShimmering
    }

    var isShowingRetryAction: Bool {
        !eventImageRetryButton.isHidden
    }
        
    var dateText: String? {
        dateLabel.text
    }
    
    var eventText: String? {
        eventLabel.text
    }
    
    var venueText: String? {
        venueLabel.text
    }
    
    var renderedImage: Data? {
        eventImageView.image?.pngData()
    }
}
