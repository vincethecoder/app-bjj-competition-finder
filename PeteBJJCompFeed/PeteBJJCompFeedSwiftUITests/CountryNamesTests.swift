//
//  CountryNamesTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/26/26.
//

import Foundation
import Testing
@testable import PeteBJJCompFeedSwiftUI

struct CountryNamesTests {
    private let portuguese = Locale(identifier: "pt_BR")
    private let greek = Locale(identifier: "el_GR")

    @Test func localized_translatesEnglishNamesIntoTheReadersLanguage() {
        #expect(CountryNames.localized("Brazil", locale: portuguese) == "Brasil")
        #expect(CountryNames.localized("Japan", locale: portuguese) == "Japão")
        #expect(CountryNames.localized("Brazil", locale: greek) == "Βραζιλία")
    }

    @Test(arguments: ["USA", "U.S.A.", "United States", "United States of America", "US", "us"])
    func localized_matchesAliasesAndCodes(country: String) {
        #expect(CountryNames.localized(country, locale: portuguese) == "Estados Unidos")
    }

    @Test func localized_ignoresCaseDiacriticsAndSurroundingSpace() {
        #expect(CountryNames.localized("  bRAZIL\n", locale: portuguese) == "Brasil")
        #expect(CountryNames.localized("Curaçao", locale: portuguese) == CountryNames.localized("Curacao", locale: portuguese))
    }

    @Test func localized_keepsTheAPIsWordingInEnglish() {
        #expect(CountryNames.localized("USA", locale: Locale(identifier: "en_US")) == "USA")
        #expect(CountryNames.localized("Brazil", locale: Locale(identifier: "en_GB")) == "Brazil")
    }

    @Test(arguments: ["country-1", "Atlantis", ""])
    func localized_showsTextThatMatchesNoCountryAsSent(country: String) {
        #expect(CountryNames.localized(country, locale: portuguese) == country)
    }

    @Test func regionCode_skipsContinentsAndOtherNonCountryRegions() {
        #expect(CountryNames.regionCode(for: "001") == nil)
        #expect(CountryNames.regionCode(for: "Brazil") == "BR")
    }
}
