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
    static let bundle = Bundle(for: CompetitionsGridViewModel.self)

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

    static var filterAll: String {
        localized("FEED_FILTER_ALL")
    }

    static var gi: String {
        localized("FEED_BADGE_GI")
    }

    static var noGi: String {
        localized("FEED_BADGE_NOGI")
    }

    static var registrationOpen: String {
        localized("FEED_BADGE_REGISTRATION_OPEN")
    }

    static var registrationClosed: String {
        localized("FEED_BADGE_REGISTRATION_CLOSED")
    }

    static var registrationNotOpen: String {
        localized("FEED_BADGE_REGISTRATION_NOT_OPEN")
    }

    static var invitationOnly: String {
        localized("FEED_BADGE_INVITATION_ONLY")
    }

    static var openEventHint: String {
        localized("FEED_CARD_OPEN_EVENT_HINT")
    }

    private static func localized(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: table)
    }
}
