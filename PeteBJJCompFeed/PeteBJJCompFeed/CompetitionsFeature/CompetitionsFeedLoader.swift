//
//  CompetitionsFeedLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

public protocol CompetitionsFeedLoader {
    typealias Result = Swift.Result<CompetitionsFeed, Error>

    /// The completion handler can be invoked in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func loadFeed(completion: @escaping (Result) -> Void)
}
