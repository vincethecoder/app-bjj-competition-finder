//
//  ErrorBannerView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

/// A tappable banner that shows a loading error until the user dismisses it.
struct ErrorBannerView: View {
    let message: String
    let dismiss: @MainActor () -> Void

    var body: some View {
        Button(action: dismiss) {
            Text(message)
                .font(.callout)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: FeedDesign.minimumTapTarget)
                .padding(.horizontal)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(.red.gradient)
        .accessibilityHint(FeedStrings.dismissErrorHint)
        .onAppear(perform: announceToVoiceOver)
    }

    /// The banner appears without focus moving to it, so VoiceOver users
    /// would otherwise not learn that loading failed.
    private func announceToVoiceOver() {
        AccessibilityNotification.Announcement(message).post()
    }
}
