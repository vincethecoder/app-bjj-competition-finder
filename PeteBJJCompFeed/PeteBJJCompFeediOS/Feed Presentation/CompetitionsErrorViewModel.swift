//
//  CompetitionsErrorViewModel.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/17/24.
//

struct CompetitionsErrorViewModel {
    let message: String?
    
    static var noError: CompetitionsErrorViewModel {
        CompetitionsErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> CompetitionsErrorViewModel {
        CompetitionsErrorViewModel(message: message)
    }
}
