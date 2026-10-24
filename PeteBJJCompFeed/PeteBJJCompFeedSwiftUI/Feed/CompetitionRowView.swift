//
//  CompetitionRowView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI

struct CompetitionRowView: View {
    let row: CompetitionRow

    var body: some View {
        VStack(alignment: .leading) {
            Text(row.dates, format: .interval.month(.abbreviated).day())
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(row.name)
                .font(.headline)

            Label(row.location, systemImage: "mappin.and.ellipse")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
    }
}
