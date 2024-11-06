//
//  CompetitionsViewController+TestHelpers.swift
//  PeteBJJCompFeediOSTests
//
//  Created by Kobe Sam on 11/4/24.
//

import UIKit
import PeteBJJCompFeediOS

extension CompetitionsViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateCompetitionViewVisible(at index: Int) -> CompetitionsCell? {
        return competitionsView(at: index) as? CompetitionsCell
    }
    
    func simulateCompetitionsViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: competitionsSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateCompetitionsViewNotNearVisible(at row: Int) {
        simulateCompetitionsViewNearVisible(at: row)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: row, section: competitionsSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func numberOfRenderedCompetitionViews() -> Int {
        tableView.numberOfRows(inSection: competitionsSection)
    }
    
    func competitionsView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: competitionsSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    private var competitionsSection: Int { 0 }
}