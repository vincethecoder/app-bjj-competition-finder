//
//  CompetitionsScreen+EmptyState.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

extension CompetitionsScreen {
    /// The copy to show when the screen has no cards.
    public struct EmptyState: Codable, Equatable, Sendable {
        public let title: String?
        public let message: String?

        public init(title: String?, message: String?) {
            self.title = title
            self.message = message
        }
    }
}
