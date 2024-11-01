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
            ),
            EventViewModel(
                dateRange: "Nov 25 - Nov 26",
                title: "Tampa Kids International Open IBJJF Jiu-Jitsu Championship 2024",
                location: "Wiregrass Ranch Sports Campus, Wesley Chapel",
                color: .systemOrange
            ),
            EventViewModel(
                dateRange: "Dec 2",
                title: "Tampa Kids International Open IBJJF Jiu-Jitsu Championship 2024",
                location: "Wiregrass Ranch Sports Campus, Wesley Chapel",
                color: .systemBrown
            ),
            EventViewModel(
                dateRange: "Dec 3 - Dec 4",
                title: "Tampa Kids International Open IBJJF Jiu-Jitsu Championship 2024",
                location: "Wiregrass Ranch Sports Campus, Wesley Chapel",
                color: .systemPurple
            ),
            EventViewModel(
                dateRange: "Dec 15",
                title: "Tampa Kids International Open IBJJF Jiu-Jitsu Championship 2024",
                location: "Wiregrass Ranch Sports Campus, Wesley Chapel",
                color: .systemYellow
            )
        ]
    }
}
