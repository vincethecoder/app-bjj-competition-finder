//
//  CompetitionsUIComposer.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/5/24.
//

import UIKit
import PeteBJJCompFeed

public final class CompetitionsUIComposer {
    private init() {}

    public static func competitionsComposedWith(competitionsLoader: CompetitionsLoader, imageLoader: EventImageDataLoader) -> CompetitionsViewController {

        let presentationAdapter = CompetitionsLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: competitionsLoader))
        
        let competitionsController = makeCompetitionsViewController(
            delegate: presentationAdapter,
            title: CompetitionsPresenter.title)
        
        presentationAdapter.presenter = CompetitionsPresenter(
            competitionsView: CompetitionsViewAdapter(
                controller: competitionsController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(competitionsController),
            errorView: WeakRefVirtualProxy(competitionsController))

        return competitionsController
    }
    private static func makeCompetitionsViewController(delegate: CompetitionsViewControllerDelegate, title: String) -> CompetitionsViewController {
        let bundle = Bundle(for: CompetitionsViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let competitionsController = storyboard.instantiateInitialViewController() as! CompetitionsViewController
        competitionsController.delegate = delegate
        competitionsController.title = title
        return competitionsController
    }
}
