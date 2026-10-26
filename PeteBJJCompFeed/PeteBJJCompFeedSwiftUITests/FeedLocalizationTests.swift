//
//  FeedLocalizationTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
@testable import PeteBJJCompFeedSwiftUI

struct FeedLocalizationTests {
    private let table = "Localizable"

    @Test func localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() throws {
        let bundle = Bundle(for: CompetitionsGridViewModel.self)
        let localizations = bundle.localizations.filter { $0 != "Base" }
        let keys = try allLocalizedKeys(in: localizations, of: bundle)

        #expect(Set(localizations) == ["en", "pt-BR", "el"])
        #expect(!keys.isEmpty)

        for localization in localizations {
            let localizedBundle = try #require(bundle.path(forResource: localization, ofType: "lproj").flatMap(Bundle.init(path:)))

            for key in keys {
                let value = localizedBundle.localizedString(forKey: key, value: nil, table: table)
                #expect(value != key, "Missing \(localization) localization for key '\(key)'")
            }
        }
    }

    @Test func registrationLabels_readAsShortCallsToActionWhileTheFilterKeepsItsDescription() {
        #expect(english(.feedBadgeRegistrationOpen) == "Register")
        #expect(english(.feedBadgeRegistrationClosed) == "Ended")
        #expect(english(.feedFilterRegistrationOpen) == "Registration open")
    }

    /// With Favorites on and nothing starred there's no card to open, and the
    /// reset item also turns Favorites off, so both say so.
    @Test func favoritesCopy_pointsBackToTheFullFeedAndNamesEverythingResetClears() {
        #expect(english(.feedFavoritesEmptyDescription) == "Turn off Favorites to browse events, then open one and tap the star.")
        #expect(english(.feedRefineReset) == "Show all dates, locations, and favorites")
    }

    // MARK: - Helpers

    private func english(_ resource: LocalizedStringResource) -> String {
        var resource = resource
        resource.locale = Locale(identifier: "en")
        return String(localized: resource)
    }

    private func allLocalizedKeys(in localizations: [String], of bundle: Bundle) throws -> Set<String> {
        try localizations.reduce(into: Set<String>()) { keys, localization in
            let path = try #require(bundle.path(forResource: table, ofType: "strings", inDirectory: nil, forLocalization: localization))
            let strings = try #require(NSDictionary(contentsOfFile: path) as? [String: String])
            keys.formUnion(strings.keys)
        }
    }
}
