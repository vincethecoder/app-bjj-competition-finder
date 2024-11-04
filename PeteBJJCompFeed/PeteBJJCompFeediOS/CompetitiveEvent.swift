//
//  CompetitiveEvent.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/3/24.
//

import Foundation

public struct CompetitiveEvent {
    public let date: String
    public let name: String
    public let venue: String
    public let url: URL
    
    public init(date: String, name: String, venue: String, url: URL) {
        self.date = date
        self.name = name
        self.venue = venue
        self.url = url
    }
}
