//
//  CompetitionsScreen+Badge.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

extension CompetitionsScreen {
    /// A small status chip on a card. The server names a semantic token;
    /// clients map it to their own colors.
    public struct Badge: Codable, Equatable, Identifiable, Sendable {
        public enum Token: String, Codable, Sendable {
            case type
            case registrationOpen
            case registrationClosed
            case neutral
        }

        public let id: String
        public let title: String
        public let token: Token

        public init(id: String, title: String, token: Token) {
            self.id = id
            self.title = title
            self.token = token
        }
    }
}
