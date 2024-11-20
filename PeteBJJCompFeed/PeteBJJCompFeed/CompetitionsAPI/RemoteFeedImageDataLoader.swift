//
//  RemoteFeedImageDataLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 11/20/24.
//

import Foundation

public final class RemoteFeedImageDataLoader: EventImageDataLoader {
    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private final class HTTPClientTaskWrapper: EventImageDataLoaderTask {
        private var completion: ((EventImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (EventImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: EventImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }

    public func loadImageData(from url: URL, completion: @escaping (EventImageDataLoader.Result) -> Void) -> EventImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
        }
        return task
    }
}
