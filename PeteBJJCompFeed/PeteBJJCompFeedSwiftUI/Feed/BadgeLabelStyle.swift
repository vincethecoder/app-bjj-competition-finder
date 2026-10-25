//
//  BadgeLabelStyle.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import SwiftUI

/// Icon then title with a fixed gap, independent of the container's label style.
/// The icon sits on the first line, as in the system style, when the title wraps.
struct BadgeLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: FeedDesign.badgeSpacing) {
            configuration.icon
            configuration.title
        }
    }
}
