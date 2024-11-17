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
    
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        let bundle = Bundle(for: CompetitionsViewController.self)
        let localizedKey = "FEED_VIEW_TITLE"
        let localizedTitle = bundle.localizedString(forKey: localizedKey, value: nil, table: "Feed")
        XCTAssertEqual(sut.title, localizedTitle)
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCompetitionsCallCount, 0, "Expected no loading requests before view is loaded")
        
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
        
        sut.simulateCompetitionsViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [event01.eventLink], "Expected one cancelled image URL request once first image is not visible anymore")
        
        sut.simulateCompetitionsViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [event01.eventLink, event02.eventLink], "Expected two cancelled image URL requests once second image is also not visible anymore")
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
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [uniqueCompetition])
        
        let view = sut.simulateCompetitionsViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData)
        
        XCTAssertNil(view?.renderedImage, "Expected no rendered image when an image load finishes after the view is not visible anymore")
    }
    
    func test_feedImageView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [uniqueCompetition, uniqueCompetition])
        
        let view0 = try XCTUnwrap(sut.simulateCompetitionViewVisible(at: 0))
        view0.prepareForReuse()
        
        let imageData0 = anyImageData
        loader.completeImageLoading(with: imageData0, at: 0)
        
        XCTAssertEqual(view0.renderedImage, .none, "Expected no image state change for reused view once image loading completes successfully")
    }
    
    func test_feedImageView_showsDataForNewViewRequestAfterPreviousViewIsReused() throws {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [uniqueCompetition, uniqueCompetition])
        
        let previousView = try XCTUnwrap(sut.simulateCompetitionsViewNotVisible(at: 0))
        
        let newView = try XCTUnwrap(sut.simulateCompetitionViewVisible(at: 0))
        previousView.prepareForReuse()
        
        let imageData = anyImageData
        loader.completeImageLoading(with: imageData, at: 1)
        
        XCTAssertEqual(newView.renderedImage, imageData)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: CompetitionsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CompetitionsUIComposer.competitionsComposedWith(competitionsLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
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
    
    private var anyImageData: Data {
        UIImage.make(withColor: .red).pngData()!
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
