//
//  PosterBadge.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import PeteBJJCompFeed

public struct PosterBadge: Identifiable, Hashable, Sendable {
    public typealias Token = CompetitionsScreen.Badge.Token

    public let id: String
    public let title: String
    public let token: Token

    public init(id: String, title: String, token: Token) {
        self.id = id
        self.title = title
        self.token = token
    }
}
