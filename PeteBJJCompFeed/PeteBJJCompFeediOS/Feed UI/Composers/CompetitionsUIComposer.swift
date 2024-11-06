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

    public static func competitionsComposedWith(competitionLoader: CompetitionsLoader, imageLoader: EventImageDataLoader) -> CompetitionsViewController {
        let refreshController = CompetitionsRefreshViewController(competitionLoader: competitionLoader)
        let competitionsController = CompetitionsViewController(refreshController: refreshController)
        refreshController.onRefresh = { [weak competitionsController] competition in
            competitionsController?.tableModel = competition.map { model in
                CompetitionsCellController(model: model, imageLoader: imageLoader)
            }
        }
        return competitionsController
    }
}
