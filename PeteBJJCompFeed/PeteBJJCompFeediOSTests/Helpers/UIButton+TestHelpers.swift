//
//  UIButton+TestHelpers.swift
//  PeteBJJCompFeediOSTests
//
//  Created by Kobe Sam on 11/4/24.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
