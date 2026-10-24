//
//  FeedStrings.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// Localized strings for the feed, read from this framework's string catalog.
enum FeedStrings {
    static let table = "Localizable"
    static let bundle = Bundle(for: CompetitionsListViewModel.self)

    static var title: String {
        localized("FEED_VIEW_TITLE")
    }

    static var connectionError: String {
        localized("FEED_VIEW_CONNECTION_ERROR")
    }

    static var emptyTitle: String {
        localized("FEED_VIEW_EMPTY_TITLE")
    }

    static var emptyDescription: String {
        localized("FEED_VIEW_EMPTY_DESCRIPTION")
    }

    static var dismissErrorHint: String {
        localized("FEED_VIEW_DISMISS_ERROR_HINT")
    }

    private static func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: table)
    }
}
