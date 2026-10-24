//
//  PreviewCompetitionsLoader.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

#if DEBUG
import Foundation
import PeteBJJCompFeed

/// Feeds SwiftUI previews with fixed results, without networking or Core Data.
final class PreviewCompetitionsLoader: CompetitionsLoader {
    struct PreviewError: Error {}

    private let result: CompetitionsLoader.Result

    init(result: CompetitionsLoader.Result) {
        self.result = result
    }

    func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
        completion(result)
    }

    static let sampleCompetitions = [
        Competition(
            id: "worlds-2026",
            name: "World IBJJF Jiu-Jitsu Championship",
            startDate: Date(timeIntervalSince1970: 1_780_099_200),
            endDate: Date(timeIntervalSince1970: 1_780_358_400),
            venue: "Walter Pyramid",
            city: "Long Beach",
            state: "CA",
            country: "USA",
            type: .gi,
            status: .upcoming,
            registrationStatus: .open,
            registrationLink: nil,
            eventLink: URL(string: "https://ibjjf.com")!,
            categories: [.adult, .master],
            rankingPoints: 1000,
            notes: nil),
        Competition(
            id: "brasileiro-2026",
            name: "Campeonato Brasileiro de Jiu-Jitsu",
            startDate: Date(timeIntervalSince1970: 1_777_507_200),
            endDate: Date(timeIntervalSince1970: 1_777_766_400),
            venue: "Ginásio do Ibirapuera",
            city: "São Paulo",
            state: nil,
            country: "Brazil",
            type: .gi,
            status: .upcoming,
            registrationStatus: .notOpen,
            registrationLink: nil,
            eventLink: URL(string: "https://ibjjf.com")!,
            categories: [.adult],
            rankingPoints: 700,
            notes: nil),
    ]
}
#endif
