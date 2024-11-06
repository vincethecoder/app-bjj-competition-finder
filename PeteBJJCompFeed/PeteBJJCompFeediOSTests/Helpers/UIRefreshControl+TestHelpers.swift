//
//  UIRefreshControl+TestHelpers.swift
//  PeteBJJCompFeediOSTests
//
//  Created by Kobe Sam on 11/4/24.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
