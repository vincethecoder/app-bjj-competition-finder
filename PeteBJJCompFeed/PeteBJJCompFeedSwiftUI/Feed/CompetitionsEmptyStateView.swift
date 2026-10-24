//
//  CompetitionsEmptyStateView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

struct CompetitionsEmptyStateView: View {
    let isLoading: Bool
    let title: String
    let message: String

    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            ContentUnavailableView(title, systemImage: "figure.martial.arts", description: Text(message))
        }
    }
}
