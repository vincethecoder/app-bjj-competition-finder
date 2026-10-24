//
//  LossyDecodableArray.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// Decodes the elements of a JSON array that it can, and skips the rest.
/// Server-driven content can add element kinds the app doesn't know yet;
/// one unknown element shouldn't throw away the whole array.
struct LossyDecodableArray<Element: Decodable>: Decodable {
    let elements: [Element]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = [Element]()

        while !container.isAtEnd {
            // Decoding through a wrapper that never throws moves the container
            // past elements that fail to decode, instead of stopping on them.
            if let element = try container.decode(LossyElement<Element>.self).value {
                elements.append(element)
            }
        }

        self.elements = elements
    }
}

private struct LossyElement<Value: Decodable>: Decodable {
    let value: Value?

    init(from decoder: Decoder) throws {
        value = try? Value(from: decoder)
    }
}
