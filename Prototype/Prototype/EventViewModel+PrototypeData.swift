//
//  EventViewModel+PrototypeData.swift
//  Prototype
//
//  Created by Kobe Sam on 10/31/24.
//

import Foundation

extension EventViewModel {
    static var protoypeEvents: [EventViewModel] {
        return [
            EventViewModel(
                dateRange: "Nov 23 - Nov 24",
                title: "Itajaí International Open IBJJF Jiu-Jitsu No-Gi Championship 2024",
                location: "Ginásio Gabriel Colares, Itajaí",
                color: .systemBlue
            ),
            EventViewModel(
                dateRange: "Nov 24",
                title: "Waco Kids International Open IBJJF Jiu-Jitsu Championship 2024",
                location: "Extraco Event Center, Waco",
                color: .systemGreen
            ),
            EventViewModel(
                dateRange: "Nov 24",
                title: "Tampa Kids International Open IBJJF Jiu-Jitsu Championship 2024",
                location: "Wiregrass Ranch Sports Campus, Wesley Chapel",
                color: .systemRed
            )
        ]
    }
}
