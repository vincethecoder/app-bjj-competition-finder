//
//  BadgeCapsuleView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// A status chip. The server picks the token; the app picks the color, and
/// each token also has its own symbol, so meaning doesn't rely on color alone.
struct BadgeCapsuleView: View {
    let badge: PosterBadge

    /// Half the height of a one-line badge, so a single line reads as a capsule
    /// and a badge that wraps on a narrow poster keeps its text inside the corners.
    @ScaledMetric(relativeTo: .caption) private var cornerRadius: CGFloat = 13

    var body: some View {
        // Badges wrap rather than truncate: a cut-off status loses its meaning.
        Label {
            Text(badge.title)
        } icon: {
            Image(systemName: symbolName)
                .foregroundStyle(tint)
        }
        // A List widens the gap after a label's icon; badges keep theirs tight
        // wherever they're drawn, including the detail screen's header.
        .labelStyle(BadgeLabelStyle())
        .font(.caption)
        .bold()
        .padding(.horizontal, FeedDesign.cardPadding)
        .padding(.vertical, FeedDesign.badgeSpacing)
        .background(.regularMaterial, in: .rect(cornerRadius: cornerRadius))
    }

    private var symbolName: String {
        switch badge.token {
        case .type: "tag.fill"
        case .registrationOpen: "checkmark.circle.fill"
        case .registrationClosed: "xmark.circle.fill"
        case .neutral: "clock.fill"
        @unknown default: "circle.fill"
        }
    }

    private var tint: Color {
        switch badge.token {
        case .type: .blue
        case .registrationOpen: .green
        case .registrationClosed: .red
        case .neutral: .gray
        @unknown default: .gray
        }
    }
}
