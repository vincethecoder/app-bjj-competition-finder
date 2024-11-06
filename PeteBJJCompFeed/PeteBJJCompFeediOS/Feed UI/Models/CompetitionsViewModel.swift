//
//  CompetitionsViewModel.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/5/24.
//

import Foundation
import PeteBJJCompFeed

final class CompetitionsViewModel {
    private let competitionsLoader: CompetitionsLoader
    
    init(competitionsLoader: CompetitionsLoader) {
        self.competitionsLoader = competitionsLoader
    }
    
    var onChange: ((CompetitionsViewModel) -> Void)?
    var onCompetitionsLoad: (([Competition]) -> Void)?

    private(set) var isLoading: Bool = false {
        didSet { onChange?(self) }
    }
    
    func loadCompetitions() {
        isLoading = true
        competitionsLoader.load { [weak self] result in
            if let competitions = try? result.get() {
                self?.onCompetitionsLoad?(competitions)
            }
            self?.isLoading = false
        }
    }
}
