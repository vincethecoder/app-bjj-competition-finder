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
            dates
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

    /// An interval needs two different dates, so a one-day event shows its date alone.
    private var dates: Text {
        let start = row.dates.lowerBound
        let end = row.dates.upperBound

        if start < end {
            return Text(start..<end, format: .interval.month(.abbreviated).day())
        } else {
            return Text(start, format: .dateTime.month(.abbreviated).day())
        }
    }
}
