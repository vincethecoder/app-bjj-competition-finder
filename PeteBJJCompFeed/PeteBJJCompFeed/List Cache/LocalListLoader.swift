//
//  LocalListLoader.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/21/24.
//

import Foundation

public final class LocalListLoader {
    private let store: ListStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public init(store: ListStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ items: [Competition], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedList { [weak self] error in
            guard let self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [Competition], with completion: @escaping (SaveResult) -> Void) {
        store.insert(items, timestamp: self.currentDate()){ [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

public protocol ListStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedList(compeletion: @escaping DeletionCompletion)
    func insert(_ items: [Competition], timestamp: Date, completion: @escaping InsertionCompletion)
}
