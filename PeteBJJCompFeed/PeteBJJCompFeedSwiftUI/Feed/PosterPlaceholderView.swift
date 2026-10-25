//
//  PosterPlaceholderView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// A quiet stand-in for missing artwork: the event's initial on a soft gradient.
struct PosterPlaceholderView: View {
    let initial: String

    var body: some View {
        Rectangle()
            .fill(.tint.quaternary)
            .overlay {
                Text(initial)
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(.secondary)
            }
    }
}
