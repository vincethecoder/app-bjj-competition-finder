//
//  PosterScreenMapper.swift
//  PeteBJJCompFeedSwiftUI
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation
import PeteBJJCompFeed

/// Turns a loaded feed into the screen the grid draws.
///
/// The server's `screen` decides what is shown and in which order. When a feed
/// has no screen, from an older server or an older cache, the mapper builds an
/// equivalent one from the competitions, so both render the same grid.
enum PosterScreenMapper {
    static func map(_ feed: CompetitionsFeed, locale: Locale, calendar: Calendar) -> PosterScreen {
        let dates = PosterDateFormatting(locale: locale, calendar: calendar)

        if let screen = feed.screen {
            return map(screen, competitions: feed.competitions, dates: dates)
        }

        return deviceScreen(for: feed.competitions, dates: dates)
    }

    // MARK: - Server-driven screen

    private static func map(_ screen: CompetitionsScreen, competitions: [Competition], dates: PosterDateFormatting) -> PosterScreen {
        let competitionsByID = Dictionary(competitions.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        let sections = screen.sections.compactMap { section -> PosterSection? in
            var seenIDs = Set<String>()
            let cards = section.cards
                // When the payload has competitions, every card must present one of them.
                .filter { competitions.isEmpty || competitionsByID[$0.id] != nil }
                // A repeated card would give the grid two views with one identity.
                .filter { seenIDs.insert($0.id).inserted }
                .map { card(for: $0, competition: competitionsByID[$0.id], dates: dates) }

            return cards.isEmpty ? nil : PosterSection(id: section.id, title: section.title, cards: cards)
        }

        return PosterScreen(
            title: screen.title.nonEmpty ?? localized(.feedViewTitle, dates.locale),
            emptyTitle: screen.empty?.title.nonEmpty ?? localized(.feedViewEmptyTitle, dates.locale),
            emptyMessage: screen.empty?.message.nonEmpty ?? localized(.feedViewEmptyDescription, dates.locale),
            filters: screen.filters.map { PosterFilter(id: $0.id, title: $0.title, criterion: $0.criterion) },
            sections: sections)
    }

    private static func card(for card: CompetitionsScreen.Card, competition: Competition?, dates: PosterDateFormatting) -> PosterCard {
        PosterCard(
            id: card.id,
            name: card.name,
            dateText: card.dateLabel.nonEmpty
                ?? dates.eventDates(from: card.startDate ?? competition?.startDate, to: card.endDate ?? competition?.endDate),
            locationText: card.locationLabel.nonEmpty ?? competition.flatMap { location(of: $0, locale: dates.locale) },
            imageURL: card.imageURL,
            eventLink: card.eventLink,
            badges: card.badges.map { PosterBadge(id: $0.id, title: $0.title, token: $0.token) },
            details: competition.map { details(for: $0, locale: dates.locale) },
            type: competition?.type.rawValue ?? card.badges.first { $0.token == .type }?.id,
            registrationStatus: competition?.registrationStatus.rawValue ?? registrationStatus(from: card.badges),
            startDate: card.startDate ?? competition?.startDate,
            endDate: card.endDate ?? competition?.endDate,
            country: competition.flatMap { country(of: $0, locale: dates.locale) })
    }

    private static func registrationStatus(from badges: [CompetitionsScreen.Badge]) -> String? {
        badges.lazy.compactMap { badge -> String? in
            switch badge.token {
            case .registrationOpen: RegistrationStatus.open.rawValue
            case .registrationClosed: RegistrationStatus.closed.rawValue
            case .type, .neutral: nil
            @unknown default: nil
            }
        }.first
    }

    // MARK: - Screen built on the device

    private static func deviceScreen(for competitions: [Competition], dates: PosterDateFormatting) -> PosterScreen {
        let locale = dates.locale

        return PosterScreen(
            title: localized(.feedViewTitle, locale),
            emptyTitle: localized(.feedViewEmptyTitle, locale),
            emptyMessage: localized(.feedViewEmptyDescription, locale),
            filters: [
                PosterFilter(id: "all", title: localized(.feedFilterAll, locale), criterion: .all),
                PosterFilter(id: "gi", title: localized(.feedBadgeGi, locale), criterion: .type(CompetitionType.gi.rawValue)),
                PosterFilter(id: "nogi", title: localized(.feedBadgeNogi, locale), criterion: .type(CompetitionType.nogi.rawValue)),
                PosterFilter(id: "open", title: localized(.feedFilterRegistrationOpen, locale), criterion: .registrationStatus(RegistrationStatus.open.rawValue)),
            ],
            sections: monthSections(for: competitions, dates: dates))
    }

    /// Groups competitions into one section per month, in date order.
    private static func monthSections(for competitions: [Competition], dates: PosterDateFormatting) -> [PosterSection] {
        let sorted = competitions.sorted { firstDay(of: $0) < firstDay(of: $1) }
        var sections = [(id: String, title: String, cards: [PosterCard])]()

        for competition in sorted {
            let start = firstDay(of: competition)
            let month = dates.calendar.dateComponents([.year, .month], from: start)
            let id = "\(month.year ?? 0)-\(month.month ?? 0)"

            if sections.last?.id == id {
                sections[sections.count - 1].cards.append(card(for: competition, dates: dates))
            } else {
                sections.append((id, dates.month(of: start), [card(for: competition, dates: dates)]))
            }
        }

        return sections.map { PosterSection(id: $0.id, title: $0.title, cards: $0.cards) }
    }

    private static func card(for competition: Competition, dates: PosterDateFormatting) -> PosterCard {
        PosterCard(
            id: competition.id,
            name: competition.name,
            dateText: dates.eventDates(from: competition.startDate, to: competition.endDate),
            locationText: location(of: competition, locale: dates.locale),
            imageURL: nil,
            eventLink: competition.eventLink,
            badges: [typeBadge(for: competition.type, locale: dates.locale), registrationBadge(for: competition.registrationStatus, locale: dates.locale)],
            details: details(for: competition, locale: dates.locale),
            type: competition.type.rawValue,
            registrationStatus: competition.registrationStatus.rawValue,
            startDate: competition.startDate,
            endDate: competition.endDate,
            country: country(of: competition, locale: dates.locale))
    }

    private static func typeBadge(for type: CompetitionType, locale: Locale) -> PosterBadge {
        switch type {
        case .gi: PosterBadge(id: type.rawValue, title: localized(.feedBadgeGi, locale), token: .type)
        case .nogi: PosterBadge(id: type.rawValue, title: localized(.feedBadgeNogi, locale), token: .type)
        @unknown default: PosterBadge(id: type.rawValue, title: type.rawValue, token: .type)
        }
    }

    private static func registrationBadge(for status: RegistrationStatus, locale: Locale) -> PosterBadge {
        switch status {
        case .open: PosterBadge(id: status.rawValue, title: localized(.feedBadgeRegistrationOpen, locale), token: .registrationOpen)
        case .closed: PosterBadge(id: status.rawValue, title: localized(.feedBadgeRegistrationClosed, locale), token: .registrationClosed)
        case .notOpen: PosterBadge(id: status.rawValue, title: localized(.feedBadgeRegistrationNotOpen, locale), token: .neutral)
        case .invitationOnly: PosterBadge(id: status.rawValue, title: localized(.feedBadgeInvitationOnly, locale), token: .neutral)
        @unknown default: PosterBadge(id: status.rawValue, title: status.rawValue, token: .neutral)
        }
    }

    // MARK: - Details

    private static func details(for competition: Competition, locale: Locale) -> PosterEventDetails {
        PosterEventDetails(
            venue: competition.venue.nonEmpty,
            divisionsText: competition.categories.isEmpty
                ? nil
                : competition.categories.map { division(for: $0, locale: locale) }.formatted(.list(type: .and).locale(locale)),
            rankingPoints: competition.rankingPoints > 0 ? competition.rankingPoints : nil,
            notes: competition.notes?.trimmingCharacters(in: .whitespacesAndNewlines).nonEmpty,
            registrationLink: competition.registrationStatus == .open ? competition.registrationLink : nil)
    }

    private static func division(for category: CompetitionCategory, locale: Locale) -> String {
        switch category {
        case .kids: localized(.detailDivisionKids, locale)
        case .juvenile: localized(.detailDivisionJuvenile, locale)
        case .adult: localized(.detailDivisionAdult, locale)
        case .master: localized(.detailDivisionMaster, locale)
        @unknown default: category.rawValue
        }
    }

    // MARK: - Helpers

    /// Copy the device supplies sits in the screen next to the server's strings,
    /// so it's resolved here, in the same locale the dates are formatted in.
    private static func localized(_ resource: LocalizedStringResource, _ locale: Locale) -> String {
        var resource = resource
        resource.locale = locale
        return String(localized: resource)
    }

    /// The country in the reader's language, which is also the value the
    /// location refinement matches on.
    private static func country(of competition: Competition, locale: Locale) -> String? {
        competition.country.nonEmpty.map { CountryNames.localized($0, locale: locale) }
    }

    private static func firstDay(of competition: Competition) -> Date {
        min(competition.startDate, competition.endDate)
    }

    /// "Long Beach, CA, USA", skipping parts that are missing or empty.
    private static func location(of competition: Competition, locale: Locale) -> String? {
        [competition.city, competition.state, country(of: competition, locale: locale)]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
            .nonEmpty
    }
}

private extension Optional<String> {
    /// The string, or `nil` when it's missing or empty.
    var nonEmpty: String? {
        self?.nonEmpty
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}
