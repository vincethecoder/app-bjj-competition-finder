//
//  CompetitionsImagePresenter.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/16/24.
//

import Foundation
import PeteBJJCompFeed

protocol CompetitionsImageView {
    associatedtype Image
    
    func display(_ model: CompetitionsImageViewModel<Image>)
}

final class CompetitionsImagePresenter<View: CompetitionsImageView, Image> where View.Image == Image {
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    internal init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: CompetitiveEvent) {
        view.display(CompetitionsImageViewModel(
            date: model.date,
            name: model.name,
            venue: model.venue,
            url: model.url,
            image: nil,
            isLoading: true,
            shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error { }
    
    func didFinishLoadingImageData(with data: Data, for model: CompetitiveEvent) {
        guard let image = imageTransformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(CompetitionsImageViewModel(
            date: model.date,
            name: model.name,
            venue: model.venue,
            url: model.url,
            image: image,
            isLoading: false,
            shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: CompetitiveEvent) {
        view.display(CompetitionsImageViewModel(
            date: model.date,
            name: model.name,
            venue: model.venue,
            url: model.url,
            image: nil,
            isLoading: false,
            shouldRetry: true))
    }
}
