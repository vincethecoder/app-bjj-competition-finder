//
//  CompetitionsURLTests.swift
//  PeteBJJCompAppTests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
@testable import PeteBJJCompApp

struct CompetitionsURLTests {

    @Test func competitionsURL_isProductionURLByDefault() throws {
        let defaults = try makeDefaults()

        #expect(SceneDelegate.competitionsURL(defaults: defaults) == URL(string: "https://bit.ly/4hd1liM"))
    }

    @Test func competitionsURL_usesLaunchArgumentOverrideInDebugBuilds() throws {
        let defaults = try makeDefaults()
        defaults.set("http://localhost:8000/competitions.json", forKey: "CompetitionsURL")

        #expect(SceneDelegate.competitionsURL(defaults: defaults) == URL(string: "http://localhost:8000/competitions.json"))
    }

    // MARK: - Helpers

    private func makeDefaults() throws -> UserDefaults {
        let suiteName = "CompetitionsURLTests-\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}
