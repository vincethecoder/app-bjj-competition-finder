//
//  LocalCompetition+Equality.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/29/24.
//

import PeteBJJCompFeed

extension LocalCompetition: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(startDate)
        hasher.combine(endDate)
        hasher.combine(venue)
        hasher.combine(city)
        hasher.combine(state)
        hasher.combine(country)
        hasher.combine(type)
        hasher.combine(status)
        hasher.combine(registrationStatus)
        hasher.combine(registrationLink)
        hasher.combine(eventLink)
        hasher.combine(categories)
        hasher.combine(rankingPoints)
        hasher.combine(notes)
    }
}
