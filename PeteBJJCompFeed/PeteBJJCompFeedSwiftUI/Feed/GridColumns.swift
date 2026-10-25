//
//  GridColumns.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// How many poster columns fit, from the size class and the text size
/// rather than the screen width, so the grid adapts to Dynamic Type,
/// split view, and Stage Manager.
enum GridColumns {
    static func count(horizontalSizeClass: UserInterfaceSizeClass?, dynamicTypeSize: DynamicTypeSize) -> Int {
        if dynamicTypeSize >= FeedDesign.largeTextSize {
            1
        } else if horizontalSizeClass == .regular {
            3
        } else {
            2
        }
    }

    static func items(count: Int) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: FeedDesign.gridSpacing, alignment: .top), count: count)
    }
}
