//
//  SceneDelegate.swift
//  PeteBJJCompApp
//
//  Created by Kobe Sam on 11/19/24.
//

import UIKit
import PeteBJJCompFeed
import PeteBJJCompFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let url = URL(string: "https://bit.ly/4hd1liM")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let competitionsLoader = RemoteCompetitionsLoader(url: url, client: client)
        let imageLoader = RemoteFeedImageDataLoader(client: client)
        
        let competitionsViewController = CompetitionsUIComposer.competitionsComposedWith(
            competitionsLoader: competitionsLoader,
            imageLoader: imageLoader)
        
        window?.rootViewController = competitionsViewController
    }

}
