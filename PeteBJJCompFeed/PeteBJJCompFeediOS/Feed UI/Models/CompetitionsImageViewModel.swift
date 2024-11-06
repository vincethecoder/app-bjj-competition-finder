//
//  CompetitionsImageViewModel.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/6/24.
//

import UIKit
import PeteBJJCompFeed

final class CompetitionsImageViewModel {
    typealias Observer<T> = (T) -> Void

    private var task: EventImageDataLoaderTask?
    private let model: Competition
    private let imageLoader: EventImageDataLoader
    
    init(model: Competition, imageLoader: EventImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    private var event: CompetitiveEvent {
        model.toCompetitiveEvent()
    }
    
    var date: String {
        event.date
    }
    
    var name: String {
        event.name
    }
    
    var venue: String {
        event.venue
    }
    
    var onImageLoadingStateChange: Observer<Bool>?
    var onImageLoad: Observer<UIImage>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        
        task = imageLoader.loadImageData(from: event.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: EventImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
