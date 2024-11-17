//
//  CompetitionsImageDataLoaderPresentationAdapter.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/17/24.
//

import PeteBJJCompFeed

final class CompetitionsImageDataLoaderPresentationAdapter<View: CompetitionsImageView, Image>: EventImageCellControllerDelegate where View.Image == Image {
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
