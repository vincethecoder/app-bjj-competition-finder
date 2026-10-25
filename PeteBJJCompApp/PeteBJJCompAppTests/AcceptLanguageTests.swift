//
//  AcceptLanguageTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
@testable import PeteBJJCompApp

struct AcceptLanguageTests {

    @Test func header_weightsEachLanguageBelowThePreviousOne() {
        #expect(URLSessionConfiguration.acceptLanguageHeader(for: ["pt-BR", "en", "el"]) == "pt-BR, en;q=0.9, el;q=0.8")
    }

    @Test func header_isNilWithoutLanguages() {
        #expect(URLSessionConfiguration.acceptLanguageHeader(for: []) == nil)
    }

    @Test func header_keepsWeightsPositiveForLongLanguageLists() throws {
        let header = try #require(URLSessionConfiguration.acceptLanguageHeader(for: Array(repeating: "en", count: 15)))

        #expect(header.components(separatedBy: ", ").count == 10)
        #expect(header.hasSuffix("en;q=0.1"))
    }

    @Test func ephemeralConfiguration_sendsAcceptLanguageHeader() {
        let configuration = URLSessionConfiguration.ephemeral(acceptingLanguages: ["el", "en"])

        #expect(configuration.httpAdditionalHeaders?["Accept-Language"] as? String == "el, en;q=0.9")
    }

    @Test func ephemeralConfiguration_omitsHeaderWithoutLanguages() {
        let configuration = URLSessionConfiguration.ephemeral(acceptingLanguages: [])

        #expect(configuration.httpAdditionalHeaders?["Accept-Language"] == nil)
    }
}
