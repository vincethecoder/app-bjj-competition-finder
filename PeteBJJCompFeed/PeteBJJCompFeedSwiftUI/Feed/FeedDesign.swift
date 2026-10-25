//
//  FeedDesign.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// Shared layout constants for the feed, so views stay visually consistent.
/// `CGFloat` because most of them go to `CGFloat?` parameters, such as
/// `padding(_:_:)` and `frame(minHeight:)`, which don't bridge from `Double`.
enum FeedDesign {
    static let minimumTapTarget: CGFloat = 44

    /// Space between the screen edges and the content.
    static let screenInset: CGFloat = 16

    /// Space between cards, rows and sections.
    static let gridSpacing: CGFloat = 12

    /// Space between the card edge and the poster, which keeps the corners concentric.
    static let cardPadding: CGFloat = 8
    static let posterCornerRadius: CGFloat = 12
    static let cardCornerRadius = posterCornerRadius + cardPadding

    /// Width over height.
    static let posterAspectRatio: CGFloat = 3 / 4

    /// The detail screen's poster stops growing here, so the event's facts
    /// start above the fold on iPhone and the poster stays a header on iPad.
    static let detailPosterMaxWidth: CGFloat = 240

    static let chipSpacing: CGFloat = 8
    static let badgeSpacing: CGFloat = 6

    /// From this text size up, the grid shows one column and card text wraps.
    static let largeTextSize = DynamicTypeSize.xxxLarge
}
