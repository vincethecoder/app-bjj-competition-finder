//
//  UbiquitousKeyValueStoreStub.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/26/26.
//

import PeteBJJCompFeedSwiftUI

/// iCloud key-value storage held in memory.
final class UbiquitousKeyValueStoreStub: UbiquitousKeyValueStore {
    private(set) var values: [String: Any]

    init(values: [String: Any] = [:]) {
        self.values = values
    }

    func array(forKey key: String) -> [Any]? {
        values[key] as? [Any]
    }

    func set(_ value: Any?, forKey key: String) {
        values[key] = value
    }
}
