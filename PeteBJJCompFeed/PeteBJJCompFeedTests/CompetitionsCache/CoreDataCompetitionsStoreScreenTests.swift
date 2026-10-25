//
//  CoreDataCompetitionsStoreScreenTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 10/24/26.
//

import CoreData
import Foundation
import Testing
import PeteBJJCompFeed

final class CoreDataCompetitionsStoreScreenTests {
    private let leakTracker = MemoryLeakTracker()

    deinit {
        leakTracker.verify()
    }

    @Test func retrieve_deliversInsertedScreen() throws {
        let sut = try makeSUT()
        let screen = Data("any screen".utf8)

        try insert([makeFeedCompetition().local], screen: screen, into: sut)

        #expect(try retrieve(from: sut)?.screen == screen)
    }

    @Test func insert_withoutScreenRemovesPreviouslyInsertedScreen() throws {
        let sut = try makeSUT()
        try insert([makeFeedCompetition().local], screen: Data("any screen".utf8), into: sut)

        try insert([makeFeedCompetition().local], screen: nil, into: sut)

        #expect(try retrieve(from: sut)?.screen == nil)
    }

    @Test func init_migratesStoreCreatedWithPreviousModelVersion() throws {
        let storeURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        defer { removeStoreFiles(at: storeURL) }
        let timestamp = Date(timeIntervalSince1970: 1_780_099_200)
        let competition = makeFeedCompetition()
        try insertWithVersion2Model(competition, timestamp: timestamp, at: storeURL)

        let sut = try makeSUT(storeURL: storeURL)

        let cache = try #require(try retrieve(from: sut))
        #expect(cache.competitions == [competition.local])
        #expect(cache.timestamp == timestamp)
        #expect(cache.screen == nil)
    }

    // MARK: - Helpers

    private func makeSUT(storeURL: URL = URL(fileURLWithPath: "/dev/null"), sourceLocation: SourceLocation = #_sourceLocation) throws -> CoreDataCompetitionsStore {
        let sut = try CoreDataCompetitionsStore(storeURL: storeURL)
        leakTracker.track(sut, sourceLocation: sourceLocation)
        return sut
    }

    private func insert(_ competitions: [LocalCompetition], screen: Data?, into sut: CompetitionsStore) throws {
        try wait { completion in
            sut.insert(competitions, screen: screen, timestamp: .now) { completion($0) }
        }
    }

    private func retrieve(from sut: CompetitionsStore) throws -> CachedCompetitions? {
        try wait { completion in
            sut.retrieve { completion($0) }
        }
    }

    /// The store completes on its own background queue; tests wait on a semaphore,
    /// which is safe because nothing in these tests runs on that queue.
    private func wait<T>(for operation: (@escaping (Result<T, Error>) -> Void) -> Void) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var received: Result<T, Error>?
        operation { result in
            received = result
            semaphore.signal()
        }
        #expect(semaphore.wait(timeout: .now() + 5) == .success, "Timed out waiting for the store")
        return try #require(received).get()
    }

    /// Writes a cache with model version 2, which predates the `screen` attribute,
    /// the way an installed app's store looks before this update.
    private func insertWithVersion2Model(_ competition: Competition, timestamp: Date, at storeURL: URL) throws {
        let momURL = try #require(Bundle(for: CoreDataCompetitionsStore.self)
            .url(forResource: "CompetitionsStore", withExtension: "momd")?
            .appending(path: "CompetitionsStore2.mom"))
        let model = try #require(NSManagedObjectModel(contentsOf: momURL))
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try coordinator.addPersistentStore(type: .sqlite, at: storeURL)
        let context = NSManagedObjectContext(.privateQueue)
        context.persistentStoreCoordinator = coordinator

        try context.performAndWait {
            let managedCompetition = NSEntityDescription.insertNewObject(forEntityName: "ManagedCompetition", into: context)
            managedCompetition.setValuesForKeys([
                "id": competition.id,
                "name": competition.name,
                "startDate": competition.startDate,
                "endDate": competition.endDate,
                "venue": competition.venue,
                "city": competition.city,
                "country": competition.country,
                "typeRawValue": competition.type.rawValue,
                "statusRawValue": competition.status.rawValue,
                "registrationStatusRawValue": competition.registrationStatus.rawValue,
                "eventLink": competition.eventLink,
                "categoriesRawValue": competition.categories.map(\.rawValue).joined(separator: ","),
                "rankingPoints": competition.rankingPoints,
            ])
            if let state = competition.state {
                managedCompetition.setValue(state, forKey: "state")
            }

            let cache = NSEntityDescription.insertNewObject(forEntityName: "ManagedCache", into: context)
            cache.setValue(timestamp, forKey: "timestamp")
            cache.setValue(NSOrderedSet(object: managedCompetition), forKey: "competitions")

            try context.save()
        }

        try coordinator.remove(store)
    }

    private func removeStoreFiles(at storeURL: URL) {
        for suffix in ["", "-shm", "-wal"] {
            try? FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path + suffix))
        }
    }
}
