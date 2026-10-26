//
//  UbiquitousKeyValueStore.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/26/26.
//

import Foundation

/// The part of iCloud key-value storage that favorites use, so tests can
/// stand in for `NSUbiquitousKeyValueStore`.
public protocol UbiquitousKeyValueStore: AnyObject {
    func array(forKey key: String) -> [Any]?
    func set(_ value: Any?, forKey key: String)
}

extension NSUbiquitousKeyValueStore: UbiquitousKeyValueStore {}
