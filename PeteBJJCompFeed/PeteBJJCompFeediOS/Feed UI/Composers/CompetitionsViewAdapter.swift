//
//  CompetitionsViewAdapter.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/17/24.
//

import UIKit
import PeteBJJCompFeed

final class CompetitionsViewAdapter: CompetitionsView {
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
