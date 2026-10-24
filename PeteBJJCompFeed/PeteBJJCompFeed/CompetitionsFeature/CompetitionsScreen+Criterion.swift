//
//  CompetitionsScreen+Criterion.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

extension CompetitionsScreen.Filter {
    /// The closed set of fields a filter can match on.
    /// Values stay strings, so the server can add a value without a client release.
    public enum Criterion: Codable, Equatable, Sendable {
        case all
        case type(String)
        case registrationStatus(String)
    }
}
