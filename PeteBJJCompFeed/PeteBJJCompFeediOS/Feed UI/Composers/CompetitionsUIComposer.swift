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
        
        let competitionsController = CompetitionsViewController.makeWith(
            delegate: presentationAdapter,
            title: CompetitionsPresenter.title)
        
        presentationAdapter.presenter = CompetitionsPresenter(
            competitionsView: CompetitionsViewAdapter(
                controller: competitionsController,
                imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)),
            loadingView: WeakRefVirtualProxy(competitionsController))

        return competitionsController
    }
}

private extension CompetitionsViewController {
    static func makeWith(delegate: CompetitionsViewControllerDelegate, title: String) -> CompetitionsViewController {
        let bundle = Bundle(for: CompetitionsViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let competitionsController = storyboard.instantiateInitialViewController() as! CompetitionsViewController
        competitionsController.delegate = delegate
        competitionsController.title = title
        return competitionsController
    }
}

private final class CompetitionsViewAdapter: CompetitionsView {
    private weak var controller: CompetitionsViewController?
    private let imageLoader: EventImageDataLoader

    init(controller: CompetitionsViewController, imageLoader: EventImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }

    func display(_ viewModel: CompetitionsViewModel) {
        controller?.tableModel = viewModel.competitions.map { model in
            let adapter = CompetitionsImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<CompetitionsCellController>, UIImage>(model: model, imageLoader: imageLoader)
            let view = CompetitionsCellController(delegate: adapter)

            adapter.presenter = CompetitionsImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)

            return view
        }
    }
}
