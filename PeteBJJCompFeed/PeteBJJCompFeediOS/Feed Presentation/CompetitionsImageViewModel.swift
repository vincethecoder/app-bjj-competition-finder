//
//  CompetitionsImageViewModel.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/16/24.
//

import Foundation

struct CompetitionsImageViewModel<Image> {
    public let date: String
    public let name: String
    public let venue: String
    public let url: URL
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
}
