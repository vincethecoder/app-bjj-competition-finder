//
//  CompetitionsViewModel.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/5/24.
//

import Foundation
import PeteBJJCompFeed

final class CompetitionsViewModel {
    typealias Observer<T> = (T) -> Void

    private let competitionsLoader: CompetitionsLoader
    
    init(competitionsLoader: CompetitionsLoader) {
        self.competitionsLoader = competitionsLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onCompetitionsLoad: Observer<[Competition]>?
    
    func loadCompetitions() {
        onLoadingStateChange?(true)
        competitionsLoader.load { [weak self] result in
            if let competitions = try? result.get() {
                self?.onCompetitionsLoad?(competitions)
            }
            self?.onLoadingStateChange?(false)
        }
    }
}
