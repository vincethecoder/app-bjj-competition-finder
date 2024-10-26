//
//  CompetitionsStoreSpecs.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/26/24.
//

import Foundation

public protocol CompetitionsStoreSpecs {
    func test_retrieve_deliversEmptyOnEmptyCache()
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversFoundValuesOnNonEmptyCache()
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache()

    func test_insert_deliversNoErrorOnEmptyCache()
    func test_insert_deliversNoErrorOnNonEmptyCache()
    func test_insert_overridesPreviouslyInsertedCacheValues()

    func test_delete_deliversNoErrorOnEmptyCache()
    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_deliversNoErrorOnNonEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

public protocol FailableRetrieveCompetitionsStoreSpecs: CompetitionsStoreSpecs {
    func test_retrieve_deliversFailureOnRetrievalError()
    func test_retrieve_hasNoSideEffectsOnFailure()
}

public protocol FailableInsertCompetitionsStoreSpecs: CompetitionsStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnInsertionError()
}

public protocol FailableDeleteCompetitionsStoreSpecs: CompetitionsStoreSpecs {
    func test_delete_deliversErrorOnDeletionError()
    func test_delete_hasNoSideEffectsOnDeletionError()
}

public typealias FailableCompetitionsStoreSpecs = FailableRetrieveCompetitionsStoreSpecs & FailableInsertCompetitionsStoreSpecs & FailableDeleteCompetitionsStoreSpecs
