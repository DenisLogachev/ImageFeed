import XCTest
@testable import ImageFeed
import UIKit

final class ImagesListPresenterTests: XCTestCase {
    var presenter: ImagesListPresenter!
    var view: ImagesListViewMock!
    var service: ImagesListServiceStub!

    override func setUp() {
        super.setUp()
        view = ImagesListViewMock()
        service = ImagesListServiceStub()
        presenter = ImagesListPresenter(view: view)
        presenter.imagesService = service
    }

    func testPhotosCount_isCorrect() {
        service.photos = [
            Photo(id: "1",
                  size: CGSize(width: 100, height: 100),
                  createdAt: nil,
                  welcomeDescription: nil,
                  thumbImageURL: "thumb",
                  fullImageURL: "url",
                  isLiked: false)
        ]
        XCTAssertEqual(presenter.numberOfPhotos, 1)
    }

    func testPhotoAtIndex_returnsCorrectPhoto() {
        let photo = Photo(id: "1",
                         size: CGSize(width: 100, height: 100),
                         createdAt: nil,
                         welcomeDescription: nil,
                         thumbImageURL: "thumb",
                         fullImageURL: "url",
                         isLiked: true)
        service.photos = [photo]
        XCTAssertEqual(presenter.photo(at: 0).id, photo.id)
    }

    func testFetchNextPage_triggersLoading() {
        presenter.fetchNextPage()
        XCTAssertTrue(service.didCallFetchNextPage)
    }

    func testToggleLike_success() {
        let photo = Photo(id: "1",
                         size: CGSize(width: 100, height: 100),
                         createdAt: nil,
                         welcomeDescription: nil,
                         thumbImageURL: "thumb",
                         fullImageURL: "url",
                         isLiked: false)
        service.photos = [photo]
        service.likeResult = .success(())

        let expectation = expectation(description: "Toggle like expectation")
        
        presenter.toggleLike(at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.view.didShowLoading)
            XCTAssertTrue(self.view.didHideLoading)
            XCTAssertEqual(self.view.updatedLikeIndex, 0)
            XCTAssertEqual(self.view.updatedLikeValue, true)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testToggleLike_failure() {
        let photo = Photo(id: "1",
                         size: CGSize(width: 100, height: 100),
                         createdAt: nil,
                         welcomeDescription: nil,
                         thumbImageURL: "thumb",
                         fullImageURL: "url",
                         isLiked: false)
        service.photos = [photo]
        service.likeResult = .failure(NSError(domain: "", code: 1))

        let expectation = expectation(description: "Toggle like failure expectation")
        
        presenter.toggleLike(at: 0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertTrue(self.view.didShowLoading)
            XCTAssertTrue(self.view.didHideLoading)
            XCTAssertTrue(self.view.didShowLikeError)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testViewDidLoad_triggersFetchNextPage() {
        presenter.viewDidLoad()
        XCTAssertTrue(service.didCallFetchNextPage)
    }
    
    func testFullImageURL_returnsCorrectURL() {
        let photo = Photo(id: "1",
                         size: CGSize(width: 100, height: 100),
                         createdAt: nil,
                         welcomeDescription: nil,
                         thumbImageURL: "thumb",
                         fullImageURL: "https://example.com/full.jpg",
                         isLiked: false)
        service.photos = [photo]
        
        let url = presenter.fullImageURL(at: 0)
        XCTAssertEqual(url?.absoluteString, "https://example.com/full.jpg")
    }
    
    func testFullImageURL_returnsNilForInvalidIndex() {
        let url = presenter.fullImageURL(at: 999)
        XCTAssertNil(url)
    }
    
    func testDidReceivePhotosUpdate_withSinglePhoto_callsReloadData() {
        let photo = Photo(id: "1",
                         size: CGSize(width: 100, height: 100),
                         createdAt: nil,
                         welcomeDescription: nil,
                         thumbImageURL: "thumb",
                         fullImageURL: "url",
                         isLiked: false)
        
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: nil,
            userInfo: ["photos": [photo]]
        )
        
        XCTAssertTrue(view.didReloadData)
    }
    
    func testFetchNextPage_doesNotTriggerLoadingWhenAlreadyLoading() {
        presenter.fetchNextPage()
        service.didCallFetchNextPage = false
        
        presenter.fetchNextPage()
        
        XCTAssertFalse(service.didCallFetchNextPage)
    }
}
