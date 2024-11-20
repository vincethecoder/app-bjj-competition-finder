//
//  UIRefreshControl+Helpers.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/19/24.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
