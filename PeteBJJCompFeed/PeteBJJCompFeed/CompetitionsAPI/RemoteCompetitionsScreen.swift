//
//  RemoteCompetitionsScreen.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

/// Decodes the server-driven `screen` payload into a `CompetitionsScreen`.
///
/// The component set is closed: filters, badges and cards the app doesn't
/// understand are skipped rather than failing the screen, and unknown keys,
/// including an unknown `layout`, are ignored.
struct RemoteCompetitionsScreen: Decodable {
    let model: CompetitionsScreen

    private enum CodingKeys: String, CodingKey {
        case title, empty, filters, sections
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        model = CompetitionsScreen(
            title: container.lenientDecode(String.self, forKey: .title),
            empty: container.lenientDecode(EmptyState.self, forKey: .empty)?.model,
            filters: container.lenientDecode(LossyDecodableArray<Filter>.self, forKey: .filters)?.elements.map(\.model) ?? [],
            sections: container.lenientDecode(LossyDecodableArray<Section>.self, forKey: .sections)?.elements.map(\.model) ?? [])
    }

    private struct EmptyState: Decodable {
        let model: CompetitionsScreen.EmptyState

        private enum CodingKeys: String, CodingKey {
            case title, message
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            model = CompetitionsScreen.EmptyState(
                title: container.lenientDecode(String.self, forKey: .title),
                message: container.lenientDecode(String.self, forKey: .message))
        }
    }

    private struct Filter: Decodable {
        let model: CompetitionsScreen.Filter

        private enum CodingKeys: String, CodingKey {
            case id, title, field, value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let field = try container.decode(String.self, forKey: .field)
            let value = container.lenientDecode(String.self, forKey: .value)

            let criterion: CompetitionsScreen.Filter.Criterion
            switch (field, value) {
            case ("none", _):
                criterion = .all
            case let ("type", value?):
                criterion = .type(value)
            case let ("registrationStatus", value?):
                criterion = .registrationStatus(value)
            default:
                throw DecodingError.dataCorruptedError(forKey: .field, in: container, debugDescription: "Unsupported filter field '\(field)'")
            }

            model = CompetitionsScreen.Filter(
                id: try container.decode(String.self, forKey: .id),
                title: try container.decode(String.self, forKey: .title),
                criterion: criterion)
        }
    }

    private struct Section: Decodable {
        let model: CompetitionsScreen.Section

        private enum CodingKeys: String, CodingKey {
            case id, title, cards
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            model = CompetitionsScreen.Section(
                id: try container.decode(String.self, forKey: .id),
                title: try container.decode(String.self, forKey: .title),
                cards: container.lenientDecode(LossyDecodableArray<Card>.self, forKey: .cards)?.elements.map(\.model) ?? [])
        }
    }

    private struct Card: Decodable {
        let model: CompetitionsScreen.Card

        private enum CodingKeys: String, CodingKey {
            case id, name, dateLabel, startDate, endDate, locationLabel, imageURL, eventLink, badges
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            model = CompetitionsScreen.Card(
                id: try container.decode(String.self, forKey: .id),
                name: try container.decode(String.self, forKey: .name),
                dateLabel: container.lenientDecode(String.self, forKey: .dateLabel),
                startDate: container.lenientDecode(String.self, forKey: .startDate).flatMap(Self.date),
                endDate: container.lenientDecode(String.self, forKey: .endDate).flatMap(Self.date),
                locationLabel: container.lenientDecode(String.self, forKey: .locationLabel),
                imageURL: container.lenientDecode(String.self, forKey: .imageURL).flatMap { URL(string: $0) },
                eventLink: try container.decode(URL.self, forKey: .eventLink),
                badges: container.lenientDecode(LossyDecodableArray<Badge>.self, forKey: .badges)?.elements.map(\.model) ?? [])
        }

        /// Parses `yyyy-MM-dd` as midnight in the current time zone, matching how
        /// competition dates are parsed. Returns `nil` instead of crashing on bad input.
        private static func date(from string: String) -> Date? {
            try? Date(string, strategy: Date.ISO8601FormatStyle(timeZone: .current).year().month().day())
        }
    }

    private struct Badge: Decodable {
        let model: CompetitionsScreen.Badge

        private enum CodingKeys: String, CodingKey {
            case id, title, token
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            model = CompetitionsScreen.Badge(
                id: try container.decode(String.self, forKey: .id),
                title: try container.decode(String.self, forKey: .title),
                token: try container.decode(CompetitionsScreen.Badge.Token.self, forKey: .token))
        }
    }
}

private extension KeyedDecodingContainer {
    /// Decodes an optional value, treating a value of the wrong type as absent.
    func lenientDecode<T: Decodable>(_ type: T.Type, forKey key: Key) -> T? {
        (try? decodeIfPresent(type, forKey: key)) ?? nil
    }
}
