//
//  CoreDataCompetitionsStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/27/24.
//

import Foundation

public final class CoreDataCompetitionsStore: CompetitionsStore {
    
    public init() {}

    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }

    public func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func deleteCachedCompetitions(completion: @escaping DeletionCompletion) {

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
