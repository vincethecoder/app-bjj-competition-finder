//
//  CompetitionsScreen+Filter.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

extension CompetitionsScreen {
    public struct Filter: Codable, Equatable, Identifiable, Sendable {
        public let id: String
        public let title: String
        public let criterion: Criterion

        public init(id: String, title: String, criterion: Criterion) {
            self.id = id
            self.title = title
            self.criterion = criterion
        }
    }
}
