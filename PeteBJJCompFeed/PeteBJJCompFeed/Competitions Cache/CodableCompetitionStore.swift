//
//  CodableCompetitionStore.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/24.
//

import Foundation

public final class CodableCompetitionStore: CompetitionsStore {

    private struct Cache: Codable {
        let competitions: [CodableCompetition]
        let timestamp: Date
        
        var localCompetitions: [LocalCompetition] {
            competitions.map { $0.local }
        }
    }
    
    private struct CodableCompetition: Codable {
        private let id: String
        private let name: String
        private let startDate: Date
        private let endDate: Date
        private let venue: String
        private let city: String
        private let state: String?
        private let country: String
        private let type: CompetitionType
        private let status: CompetitionStatus
        private let registrationStatus: RegistrationStatus
        private let registrationLink: URL?
        private let eventLink: URL
        private let categories: [CompetitionCategory]
        private let rankingPoints: Int
        private let notes: String?
        
        init(_ competition: LocalCompetition) {
            self.id = competition.id
            self.name = competition.name
            self.startDate = competition.startDate
            self.endDate = competition.endDate
            self.venue = competition.venue
            self.city = competition.city
            self.state = competition.state
            self.country = competition.country
            self.type = competition.type
            self.status = competition.status
            self.registrationStatus = competition.registrationStatus
            self.registrationLink = competition.registrationLink
            self.eventLink = competition.eventLink
            self.categories = competition.categories
            self.rankingPoints = competition.rankingPoints
            self.notes = competition.notes
        }
        
        var local: LocalCompetition {
            LocalCompetition(id: id, name: name, startDate: startDate, endDate: startDate, venue: venue, city: city, state: state, country: country, type: type, status: status, registrationStatus: registrationStatus, registrationLink: registrationLink, eventLink: eventLink, categories: categories, rankingPoints: rankingPoints, notes: notes)
        }
        
    }
    
    private let queue = DispatchQueue(label: "\(CodableCompetitionStore.self)Queue", qos: .userInitiated)
    
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                completion(.empty)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let cache = try decoder.decode(Cache.self, from: data)
                completion(.found(competitions: cache.localCompetitions, timestamp: cache.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ competitions: [LocalCompetition], timestamp: Date, completion: @escaping CompetitionsStore.InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let cache = Cache(competitions: competitions.map(CodableCompetition.init), timestamp: timestamp)
                let encoded = try! encoder.encode(cache)
                try encoded.write(to: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedCompetitions(completion: @escaping DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                completion(nil)
                return
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
