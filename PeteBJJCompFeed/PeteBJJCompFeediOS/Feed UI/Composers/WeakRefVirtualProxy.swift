//
//  WeakRefVirtualProxy.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/17/24.
//

import UIKit

final class WeakRefVirtualProxy<T: AnyObject> {
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

