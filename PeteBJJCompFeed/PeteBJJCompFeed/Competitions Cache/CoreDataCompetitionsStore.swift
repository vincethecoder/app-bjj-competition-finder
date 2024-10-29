//
//  CoreDataCompetitionsStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/27/24.
//

import CoreData

public final class CoreDataCompetitionsStore: CompetitionsStore {
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    public init(storeURL: URL, bundle: Bundle = .main) throws {
        container = try NSPersistentContainer.load(modelName: "CompetitionsStore", url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedCompetitions(completion: @escaping DeletionCompletion) {

    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(modelName name: String, url: URL, in bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = NSManagedObjectModel.with(name: name, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
                .url(forResource: name, withExtension: "momd")
                .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

extension ManagedCompetitions {
    var type: CompetitionType {
        get { CompetitionType(rawValue: typeRawValue!) ?? .gi }
        set { typeRawValue = newValue.rawValue }
    }
    
    var status: CompetitionStatus {
        get { CompetitionStatus(rawValue: statusRawValue!) ?? .upcoming }
        set { statusRawValue = newValue.rawValue }
    }
    
    var registrationStatus: RegistrationStatus {
        get { RegistrationStatus(rawValue: registrationStatusRawValue!) ?? .closed }
        set { registrationStatusRawValue = newValue.rawValue }
    }
    
    var categories: Set<CompetitionCategory> {
        get {
            guard let categoryValues = categoriesRawValue?.components(separatedBy: ",") else { return [] }
            return Set(categoryValues.compactMap { CompetitionCategory(rawValue: $0) })
        }
        set { categoriesRawValue = newValue.map { $0.rawValue }.joined(separator: ",") }
    }
}
