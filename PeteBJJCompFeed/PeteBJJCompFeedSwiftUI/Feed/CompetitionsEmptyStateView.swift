//
//  CompetitionsEmptyStateView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

struct CompetitionsEmptyStateView: View {
    let isLoading: Bool
    let title: Text
    let message: Text

    var body: some View {
        if isLoading {
            ProgressView()
        } else {
            ContentUnavailableView {
                Label {
                    title
                } icon: {
                    Image(systemName: "figure.martial.arts")
                }
            } description: {
                message
            }
        }
    }
}
