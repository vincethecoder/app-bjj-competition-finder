//
//  SceneDelegate.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 11/19/24.
//

import os
import CoreData
import UIKit
import PeteBJJCompFeed
import PeteBJJCompFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let competitionsURL = URL(string: "https://bit.ly/4hd1liM")!

    private lazy var httpClient: HTTPClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))

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
        window?.rootViewController = CompetitionsUIComposer.competitionsComposedWith(
            competitionsLoader: makeCompetitionsLoader(),
            imageLoader: RemoteFeedImageDataLoader(client: httpClient))

        window?.makeKeyAndVisible()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        localCompetitionsLoader?.validateCache { _ in }
    }

    private func makeCompetitionsLoader() -> CompetitionsLoader {
        let remoteLoader = RemoteCompetitionsLoader(url: competitionsURL, client: httpClient)

        guard let localCompetitionsLoader else { return remoteLoader }

        return CompetitionsLoaderWithFallbackComposite(
            primary: CompetitionsLoaderCacheDecorator(
                decoratee: remoteLoader,
                cache: localCompetitionsLoader),
            fallback: localCompetitionsLoader)
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
