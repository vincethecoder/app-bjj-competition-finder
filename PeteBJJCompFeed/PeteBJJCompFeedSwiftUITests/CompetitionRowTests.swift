//
//  CompetitionRowTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import Testing
import PeteBJJCompFeed
@testable import PeteBJJCompFeedSwiftUI

struct CompetitionRowTests {

    @Test func init_mapsIdNameAndDates() {
        let competition = uniqueCompetition()

        let row = CompetitionRow(competition)

        #expect(row.id == competition.id)
        #expect(row.name == competition.name)
        #expect(row.dates == competition.startDate...competition.endDate)
    }

    @Test func init_joinsVenueCityAndStateIntoLocation() {
        let row = CompetitionRow(uniqueCompetition(venue: "Walter Pyramid", city: "Long Beach", state: "CA"))

        #expect(row.location == "Walter Pyramid, Long Beach, CA")
    }

    @Test(arguments: [nil, ""])
    func init_omitsMissingStateFromLocation(state: String?) {
        let row = CompetitionRow(uniqueCompetition(venue: "Ginásio do Ibirapuera", city: "São Paulo", state: state))

        #expect(row.location == "Ginásio do Ibirapuera, São Paulo")
    }

    @Test func init_ordersDatesWhenEndDatePrecedesStartDate() {
        let earlier = Date(timeIntervalSince1970: 1_717_027_200)
        let later = Date(timeIntervalSince1970: 1_717_286_400)

        let row = CompetitionRow(uniqueCompetition(startDate: later, endDate: earlier))

        #expect(row.dates == earlier...later)
    }

    @Test func init_keepsOneDayEventAsSingleDate() {
        let day = Date(timeIntervalSince1970: 1_717_027_200)

        let row = CompetitionRow(uniqueCompetition(startDate: day, endDate: day))

        #expect(row.dates == day...day)
        #expect(row.dates.lowerBound == row.dates.upperBound)
    }
}
