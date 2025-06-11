import XCTest
@testable import ImageFeed
import UIKit

final class ImagesListServiceStub: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var didCallFetchNextPage = false
    var likeResult: Result<Void, Error>?

    func fetchPhotosNextPage() {
        didCallFetchNextPage = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = likeResult {
            completion(result)
        }
    }
    
    func clearPhotosList() {
        photos = []
    }
}
