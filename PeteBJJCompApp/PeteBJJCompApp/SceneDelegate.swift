//
//  SceneDelegate.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 11/19/24.
//

import os
import CoreData
import SwiftUI
import UIKit
import PeteBJJCompFeed
import PeteBJJCompFeedSwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var competitionsURL = Self.competitionsURL(defaults: .standard)

    private lazy var httpClient: HTTPClient = URLSessionHTTPClient(
        session: URLSession(configuration: .ephemeral(acceptingLanguages: Bundle.main.preferredLocalizations)))

    private lazy var store: CompetitionsStore? = makeCompetitionsStore()

    private lazy var localCompetitionsLoader: LocalCompetitionsLoader? = store.map {
        LocalCompetitionsLoader(store: $0, currentDate: Date.init)
    }

    private static let logger = Logger(subsystem: "com.vincethecoder.PeteBJJCompApp", category: "SceneDelegate")

    convenience init(httpClient: HTTPClient, store: CompetitionsStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        configureWindow()
    }

    func configureWindow() {
        let viewModel = CompetitionsGridViewModel(loader: makeCompetitionsFeedLoader())
        window?.rootViewController = UIHostingController(rootView: CompetitionsGridView(viewModel: viewModel))

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localCompetitionsLoader?.validateCache { _ in }
    }

    private func makeCompetitionsFeedLoader() -> CompetitionsFeedLoader {
        let remoteLoader = RemoteCompetitionsFeedLoader(url: competitionsURL, client: httpClient)

        guard let localCompetitionsLoader else { return remoteLoader }

        return CompetitionsFeedLoaderWithFallbackComposite(
            primary: CompetitionsFeedLoaderCacheDecorator(
                decoratee: remoteLoader,
                cache: localCompetitionsLoader),
            fallback: localCompetitionsLoader)
    }

    private static let defaultCompetitionsURL: URL = {
        guard let url = URL(string: "https://bit.ly/4hd1liM") else {
            fatalError("Invalid competitions URL")
        }
        return url
    }()

    /// Debug builds read `-CompetitionsURL <url>` from the launch arguments,
    /// so the app can be pointed at a local fixture server.
    static func competitionsURL(defaults: UserDefaults) -> URL {
        #if DEBUG
        if let override = defaults.string(forKey: "CompetitionsURL").flatMap(URL.init(string:)) {
            return override
        }
        #endif
        return defaultCompetitionsURL
    }

    // The app still works online without a cache, so a store that fails to
    // load degrades to remote-only loading instead of crashing.
    private func makeCompetitionsStore() -> CompetitionsStore? {
        let storeURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appending(path: "competitions-store.sqlite")

        do {
            return try CoreDataCompetitionsStore(storeURL: storeURL)
        } catch {
            Self.logger.error("Failed to create the competitions store: \(error.localizedDescription)")
            return nil
        }
    }
}
