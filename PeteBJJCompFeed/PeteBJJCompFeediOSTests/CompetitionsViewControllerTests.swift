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
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until views become visible")
        
        let (image01, image02) = (event01.toCompetitiveEvent(), event02.toCompetitiveEvent())
        sut.simulateCompetitionViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image01.url], "Expected first image URL request once first view becomes visible")
        
        sut.simulateCompetitionViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image01.url, image02.url], "Expected second image URL request once second view also becomes visible")
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")
        
        // MARK: - TODO
        
//        sut.simulateCompetitionViewNotVisible(at: 0)
//        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected one cancelled image URL request once first image is not visible anymore")
//        
//        sut.simulateFeedImageViewNotVisible(at: 1)
//        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])

        let view0 = sut.simulateCompetitionViewVisible(at: 0)
        let view1 = sut.simulateCompetitionViewVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator for first view while loading first image")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected loading indicator for second view while loading second image")
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true, "Expected no loading indicator state change for second view once first image loading completes successfully")
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator state change for first view once second image loading completes with error")
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false, "Expected no loading indicator for second view once second image loading completes with error")
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])

        let view0 = sut.simulateCompetitionViewVisible(at: 0)
        let view1 = sut.simulateCompetitionViewVisible(at: 1)
        XCTAssertEqual(view0?.renderedImage, .none, "Expected no image for first view while loading first image")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image for second view while loading second image")

        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected image for first view once first image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, .none, "Expected no image state change for second view once first image loading completes successfully")

        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(view0?.renderedImage, imageData0, "Expected no image state change for first view once second image loading completes successfully")
        XCTAssertEqual(view1?.renderedImage, imageData1, "Expected image for second view once second image loading completes successfully")
    }
    
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])
        
        let view = sut.simulateCompetitionViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (image0, image1) = (event01.toCompetitiveEvent(), event02.toCompetitiveEvent())
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])
        
        let view0 = sut.simulateCompetitionViewVisible(at: 0)
        let view1 = sut.simulateCompetitionViewVisible(at: 1)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL request for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url], "Expected third imageURL request after first view retry action")
        
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url], "Expected fourth imageURL request after second view retry action")
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (image0, image1) = (event01.toCompetitiveEvent(), event02.toCompetitiveEvent())
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image URL requests until image is near visible")
        
        sut.simulateCompetitionViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request once first image is near visible")
        
        sut.simulateCompetitionViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request once second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let competitions = uniqueCompetitions.models
        let (event01, event02) = (competitions[0], competitions[1])
        let (image0, image1) = (event01.toCompetitiveEvent(), event02.toCompetitiveEvent())
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [event01, event02])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateCompetitionsViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image URL request once first image is not near visible anymore")
        
        sut.simulateCompetitionsViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second cancelled image URL request once second image is not near visible anymore")
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
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL, completition: @escaping (EventImageDataLoader.Result) -> Void) -> any EventImageDataLoaderTask {
            imageRequests.append((url, completition))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
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
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
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
