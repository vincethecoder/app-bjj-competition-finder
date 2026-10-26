//
//  CompetitionDetailView.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/25/26.
//

import SwiftUI

/// One event in full: the poster, the facts the card has no room for, and
/// links to register and to the event website.
struct CompetitionDetailView: View {
    let card: PosterCard
    let favorites: FavoriteCompetitions

    var body: some View {
        List {
            Section {
                CompetitionDetailHeaderView(card: card)
            }

            Section {
                CompetitionDetailFactsView(card: card)
            }

            Section {
                if let registrationLink = card.details?.registrationLink {
                    Link(destination: registrationLink) {
                        Label {
                            Text(.detailRegister)
                        } icon: {
                            Image(systemName: "pencil.and.list.clipboard")
                        }
                    }
                }

                Link(destination: card.eventLink) {
                    Label {
                        Text(.detailEventWebsite)
                    } icon: {
                        Image(systemName: "safari")
                    }
                }
            }

            if let notes = card.details?.notes {
                Section {
                    Text(notes)
                } header: {
                    Text(.detailNotes)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color(.feedBackground))
        .navigationTitle(card.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            FavoriteButton(id: card.id, favorites: favorites)
            ShareLink(item: card.eventLink, subject: Text(card.name))
        }
    }
}

#if DEBUG
#Preview("Registration open") {
    NavigationStack {
        CompetitionDetailView(card: .preview(registrationLink: URL(string: "https://example.com/register")), favorites: .preview)
    }
}

#Preview("Server card without details") {
    NavigationStack {
        CompetitionDetailView(card: .preview(details: false), favorites: .preview)
    }
}

private extension PosterCard {
    static func preview(details: Bool = true, registrationLink: URL? = nil) -> PosterCard {
        PosterCard(
            id: "worlds",
            name: "World IBJJF Jiu-Jitsu Championship 2026",
            dateText: "May 28 – 31",
            locationText: "Long Beach, CA, USA",
            imageURL: nil,
            eventLink: URL(string: "https://example.com/worlds")!,
            badges: [
                PosterBadge(id: "gi", title: "Gi", token: .type),
                PosterBadge(id: "open", title: "Register", token: .registrationOpen),
            ],
            details: details
                ? PosterEventDetails(
                    venue: "Walter Pyramid",
                    divisionsText: "Juvenile, Adult and Master",
                    rankingPoints: 1000,
                    notes: "Weigh-in happens right before the first match.",
                    registrationLink: registrationLink)
                : nil,
            type: "gi",
            registrationStatus: "open",
            startDate: nil,
            endDate: nil,
            country: "USA")
    }
}
#endif
