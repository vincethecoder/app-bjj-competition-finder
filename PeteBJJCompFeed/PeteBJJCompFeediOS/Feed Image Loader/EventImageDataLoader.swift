//
//  EventImageDataLoader.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/4/24.
//

import Foundation

public protocol EventImageDataLoaderTask {
    func cancel()
}

public protocol EventImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completition: @escaping (Result) -> Void) -> EventImageDataLoaderTask
}
