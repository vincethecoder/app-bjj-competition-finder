//
//  CoreDataCompetitionsStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/27/24.
//

import CoreData

public final class CoreDataCompetitionsStore {
    private static let modelName = "CompetitionsStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataCompetitionsStore.self))
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    
    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataCompetitionsStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            container = try NSPersistentContainer.load(name: CoreDataCompetitionsStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpReferencesToPersistentStores()
    }
}

private extension NSPersistentContainer {
    enum LoadingError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
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

extension ManagedCompetition {
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
    
    var categories: [CompetitionCategory] {
        get {
            guard let categoryValues = categoriesRawValue?.components(separatedBy: ",") else { return [] }
            return categoryValues.compactMap { CompetitionCategory(rawValue: $0) }
        }
        set { categoriesRawValue = newValue.map { $0.rawValue }.joined(separator: ",") }
    }
}

extension ManagedCache {
    static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
    
    static func mapped(_ competitions: [LocalCompetition], in context: NSManagedObjectContext) -> NSOrderedSet {
        let mappedCompetitions = competitions.map { $0.toManagedObject(in: context) }
        return NSOrderedSet(array: mappedCompetitions)
    }
}

extension LocalCompetition {
    func toManagedObject(in context: NSManagedObjectContext) -> ManagedCompetition {
        let managed = ManagedCompetition(context: context)
        managed.id = id
        managed.name = name
        managed.startDate = startDate
        managed.endDate = endDate
        managed.venue = venue
        managed.city = city
        managed.state = state
        managed.country = country
        managed.type = type
        managed.status = status
        managed.registrationStatus = registrationStatus
        managed.registrationLink = registrationLink
        managed.eventLink = eventLink
        managed.categories = categories
        managed.rankingPoints = Int32(rankingPoints)
        managed.notes = notes

        return managed
    }
}

extension ManagedCompetition {
    func toModel() -> LocalCompetition? {
        guard let id, let name, let startDate, let endDate,
              let venue, let city, let country, let eventLink else {
            return nil
        }
        return LocalCompetition(
            id: id,
            name: name,
            startDate: startDate,
            endDate: endDate,
            venue: venue,
            city: city,
            state: state,
            country: country,
            type: type,
            status: status,
            registrationStatus: registrationStatus,
            registrationLink: registrationLink,
            eventLink: eventLink,
            categories: categories,
            rankingPoints: Int(rankingPoints),
            notes: notes
        )
    }
}
