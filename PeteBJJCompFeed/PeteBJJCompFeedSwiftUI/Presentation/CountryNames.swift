//
//  CountryNames.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/26/26.
//

import Foundation

/// Shows the feed's country names in the reader's language.
///
/// The API sends a country as English text, such as "Brazil" or "USA". It's
/// matched to an ISO 3166 region, whose name `Locale` knows in every language.
/// Text that matches no region is shown as sent.
enum CountryNames {
    static func localized(_ country: String, locale: Locale) -> String {
        // The API already writes in English, in its own words ("USA").
        guard locale.language.languageCode != .english,
              let code = regionCode(for: country) else { return country }

        return locale.localizedString(forRegionCode: code) ?? country
    }

    /// The ISO 3166-1 code for an English country name, an alias or a code.
    static func regionCode(for country: String) -> String? {
        codesByName[normalized(country)]
    }

    // MARK: - Helpers

    /// Common names that aren't the region's English name in `Locale`.
    private static let aliases = [
        "usa": "US",
        "u.s.a.": "US",
        "united states of america": "US",
        "uk": "GB",
        "great britain": "GB",
        "uae": "AE",
    ]

    private static let codesByName: [String: String] = {
        let english = Locale(identifier: "en")
        var codes = aliases

        // `isoRegions` also has continents such as "001"; countries have two letters.
        for region in Locale.Region.isoRegions where region.identifier.count == 2 {
            let code = region.identifier
            codes[normalized(code)] = code
            if let name = english.localizedString(forRegionCode: code) {
                codes[normalized(name)] = code
            }
        }
        return codes
    }()

    private static func normalized(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: nil)
    }
}
