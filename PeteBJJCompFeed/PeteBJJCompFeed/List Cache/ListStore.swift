//
//  ListStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/21/24.
//

import Foundation

public protocol ListStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func deleteCachedList(compeletion: @escaping DeletionCompletion)
    func insert(_ items: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion)
}
