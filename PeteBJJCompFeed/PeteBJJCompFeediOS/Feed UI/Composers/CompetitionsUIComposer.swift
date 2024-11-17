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

        let presentationAdapter = CompetitionsLoaderPresentationAdapter(feedLoader: competitionsLoader)
        
        let competitionsController = CompetitionsViewController.makeWith(
            delegate: presentationAdapter,
            title: CompetitionsPresenter.title)
        
        presentationAdapter.presenter = CompetitionsPresenter(
            competitionsView: CompetitionsViewAdapter(controller: competitionsController, imageLoader: imageLoader),
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

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?

    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: CompetitionsLoadingView where T: CompetitionsLoadingView {
    func display(_ viewModel: CompetitionsLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: CompetitionsImageView where T: CompetitionsImageView, T.Image == UIImage {
    func display(_ model: CompetitionsImageViewModel<UIImage>) {
        object?.display(model)
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

private final class CompetitionsLoaderPresentationAdapter: CompetitionsViewControllerDelegate {
    private let feedLoader: CompetitionsLoader
    var presenter: CompetitionsPresenter?

    init(feedLoader: CompetitionsLoader) {
        self.feedLoader = feedLoader
    }

    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()

        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)

            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class CompetitionsImageDataLoaderPresentationAdapter<View: CompetitionsImageView, Image>: EventImageCellControllerDelegate where View.Image == Image {
    private let model: CompetitiveEvent
    private let imageLoader: EventImageDataLoader
    private var task: EventImageDataLoaderTask?
    
    var presenter: CompetitionsImagePresenter<View, Image>?
    
    init(model: Competition, imageLoader: EventImageDataLoader) {
        self.model = model.toCompetitiveEvent()
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
