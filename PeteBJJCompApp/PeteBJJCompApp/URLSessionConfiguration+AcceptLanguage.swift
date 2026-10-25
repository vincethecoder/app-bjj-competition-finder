//
//  URLSessionConfiguration+AcceptLanguage.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 10/24/26.
//

import Foundation

extension URLSessionConfiguration {
    /// An ephemeral configuration that asks the server for its copy in the
    /// languages the app is shown in, so server-driven labels match the
    /// strings localized on the device.
    static func ephemeral(acceptingLanguages languages: [String]) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.ephemeral
        if let acceptLanguage = acceptLanguageHeader(for: languages) {
            configuration.httpAdditionalHeaders = ["Accept-Language": acceptLanguage]
        }
        return configuration
    }

    /// Weights each language below the one before it, e.g. `pt-BR, en;q=0.9`.
    static func acceptLanguageHeader(for languages: [String]) -> String? {
        guard !languages.isEmpty else { return nil }

        return languages.prefix(10).enumerated().map { index, language in
            index == 0 ? language : "\(language);q=0.\(10 - index)"
        }.joined(separator: ", ")
    }
}
