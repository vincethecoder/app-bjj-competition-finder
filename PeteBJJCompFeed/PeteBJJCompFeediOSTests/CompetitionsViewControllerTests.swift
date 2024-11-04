//
//  CompetitionsViewControllerTests.swift
//  PeteBJJCompFeedTests
//
//  Created by Kobe Sam on 11/1/24.
//

import XCTest
import PeteBJJCompFeed
import PeteBJJCompFeediOS

final class CompetitionsViewControllerTests: XCTestCase {

    func test_init_doesNotLoadCompetitions() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCompetitionsCallCount, 0)
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCompetitionsCallCount, 1, "Expected a loading request once view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCompetitionsCallCount, 2, "Expected another loading request once user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCompetitionsCallCount, 3, "Expected yet another loading request once user initiates another reload")
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")

        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loading completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates a reload")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let competitions = uniqueCompetitions.models

        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [competitions[0]], at: 0)
        assertThat(sut, isRendering: [competitions[0]])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: competitions, at: 1)
        assertThat(sut, isRendering: competitions)
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let competitions = uniqueCompetitions.models
        
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [competitions[0]], at: 0)
        assertThat(sut, isRendering: [competitions[0]])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [competitions[0]])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CompetitionsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CompetitionsViewController(loader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: CompetitionsViewController, isRendering competitions: [Competition], file: StaticString = #file, line: UInt = #line) {
        guard sut.numberOfRenderedCompetitionViews() == competitions.count else {
            return XCTFail("Expected \(competitions.count) events, got \(sut.numberOfRenderedCompetitionViews()) instead.", file: file, line: line)
        }
        
        competitions.enumerated().forEach { index, event in
            assertThat(sut, hasViewConfiguredFor: event, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: CompetitionsViewController, hasViewConfiguredFor competition: Competition, at index: Int, file: StaticString = #file, line: UInt = #line) {
        let view = sut.competitionsView(at: index)
        
        guard let cell = view as? CompetitionsCell else {
            return XCTFail("Expected \(CompetitionsCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
        }
        
        let event = competition.toCompetitiveEvent()
        XCTAssertEqual(cell.dateText, event.date, "Expected date text to be \(event.date) for competition view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.eventText, event.name, "Expected name text to be \(event.name) for competition view at index (\(index))", file: file, line: line)
        
        XCTAssertEqual(cell.venueText, event.venue, "Expected venue text to be \(event.venue) for competition view at index (\(index))", file: file, line: line)
    }
    
    private func makeCompetitiveEvent(date: String, name: String, venue: String, url: URL) -> CompetitiveEvent {
        return CompetitiveEvent(date: date, name: name, venue: venue, url: url)
    }
    
    private var uniqueCompetition: Competition {
        Competition(id: UUID().uuidString, name: "any-name", startDate: Date(), endDate: Date(), venue: "any-venue", city: "any-city", state: nil, country: "any-country", type: .gi, status: .upcoming, registrationStatus: .notOpen, registrationLink: nil, eventLink: anyURL, categories: [.adult], rankingPoints: 0, notes: nil)
    }
    
    private var uniqueCompetitions: (models: [Competition], local: [LocalCompetition]) {
        let models = [uniqueCompetition, uniqueCompetition]
        let localCompetitions = models.map {
            LocalCompetition(id: $0.id, name: $0.name, startDate: $0.startDate, endDate: $0.endDate, venue: $0.venue, city: $0.city, state: $0.state, country: $0.country, type: $0.type, status: $0.status, registrationStatus: $0.registrationStatus, registrationLink: $0.registrationLink, eventLink: $0.eventLink, categories: $0.categories, rankingPoints: $0.rankingPoints, notes: $0.notes)
        }
        return (models, localCompetitions)
    }
    
    class LoaderSpy: CompetitionsLoader, EventImageDataLoader {
        
        // MARK: - CompetitionsLoader
        
        private var competitionsRequests = [(CompetitionsLoader.Result) -> Void]()
        
        var loadCompetitionsCallCount: Int {
            competitionsRequests.count
        }
        
        func load(completion: @escaping (CompetitionsLoader.Result) -> Void) {
            competitionsRequests.append(completion)
        }
        
        func completeFeedLoading(with events: [Competition] = [], at index: Int = 0) {
            competitionsRequests[index](.success(events))
        }
        
        func completeFeedLoadingWithError(at index: Int = 0) {
            let error = anyNSError
            competitionsRequests[index](.failure(error))
        }
        
        private struct TaskSpy: EventImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completition: (EventImageDataLoader.Result) -> Void)]()
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        
        private(set) var cacelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completition: @escaping (EventImageDataLoader.Result) -> Void) -> any EventImageDataLoaderTask {
            imageRequests.append((url, completition))
            return TaskSpy { [weak self] in self?.cacelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].completition(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            let error = anyNSError
            imageRequests[index].completition(.failure(error))
        }
    }
}

private extension CompetitionsViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateEventImageViewVisible(at index: Int) -> CompetitionsCell? {
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

private extension CompetitionsCell {
    func simulateRetryAction() {
        eventImageRetryButton.simulateTap()
    }
    
    var isShowingImageLoadingIndicator: Bool {
        eventImageContainer.isShimmering
    }

    var isShowingRetryAction: Bool {
        !eventImageRetryButton.isHidden
    }
        
    var dateText: String? {
        dateLabel.text
    }
    
    var eventText: String? {
        eventLabel.text
    }
    
    var venueText: String? {
        venueLabel.text
    }
    
    var renderedImage: Data? {
        eventImageView.image?.pngData()
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndPDFContext()
        return img!
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension CompetitionsViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            replaceRefreshControlWithFakeForiOS17Support()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func replaceRefreshControlWithFakeForiOS17Support() {
        let fake = FakeRefreshControl()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                fake.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = fake
    }
}

private final class FakeRefreshControl: UIRefreshControl {
    private var _isRefreshing = false
    
    override var isRefreshing: Bool { _isRefreshing }
    
    override func beginRefreshing() {
        _isRefreshing = true
    }
    
    override func endRefreshing() {
        _isRefreshing = false
    }
}
