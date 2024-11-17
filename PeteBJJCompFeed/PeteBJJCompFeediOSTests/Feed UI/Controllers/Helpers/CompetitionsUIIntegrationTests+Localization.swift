//
//  CompetitionsUIIntegrationTests+Localization.swift
//  PeteBJJCompFeediOSTests
//
//  Created by Kobe Sam on 11/17/24.
//

import Foundation
import XCTest
import PeteBJJCompFeediOS

extension CompetitionsUIIntegrationTests {
    func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: CompetitionsViewController.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        return value
    }
}
