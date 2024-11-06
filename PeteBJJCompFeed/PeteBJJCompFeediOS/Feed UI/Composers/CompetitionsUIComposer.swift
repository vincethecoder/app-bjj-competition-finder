//
//  CompetitionsUIComposer.swift
//  PeteBJJCompFeediOS
//
//  Created by Kobe Sam on 11/5/24.
//

import Foundation
import PeteBJJCompFeed

public final class CompetitionsUIComposer {
    private init() {}

    public static func competitionsComposedWith(competitionsLoader: CompetitionsLoader, imageLoader: EventImageDataLoader) -> CompetitionsViewController {
        let competitionsViewModel = CompetitionsViewModel(competitionsLoader: competitionsLoader)
        let refreshController = CompetitionsRefreshViewController(viewModel: competitionsViewModel)
        let competitionsController = CompetitionsViewController(refreshController: refreshController)
        competitionsViewModel.onCompetitionsLoad = adaptCompetitionsToCellControllers(forwardingTo: competitionsController, loader: imageLoader)
        return competitionsController
    }
    
    private static func adaptCompetitionsToCellControllers(forwardingTo controller: CompetitionsViewController, loader: EventImageDataLoader) -> ([Competition]) -> Void {
        return { [weak controller] competition in
            controller?.tableModel = competition.map { model in
                CompetitionsCellController(model: model, imageLoader: loader)
            }
        }
    }
}
