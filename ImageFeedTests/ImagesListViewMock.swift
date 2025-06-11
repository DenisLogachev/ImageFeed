import XCTest
@testable import ImageFeed
import UIKit

final class ImagesListViewMock: ImagesListViewProtocol {
    var didShowLoading = false
    var didHideLoading = false
    var updatedPhotos: [Photo] = []
    var didShowLikeError = false
    var updatedLikeIndex: Int?
    var updatedLikeValue: Bool?
    var didReloadData = false

    func showLoading() {
        didShowLoading = true
    }

    func hideLoading() {
        didHideLoading = true
    }

    func updateTableAnimated(newPhotos: [Photo]) {
        updatedPhotos = newPhotos
    }

    func showLikeError() {
        didShowLikeError = true
    }

    func updateLikeState(at index: Int, isLiked: Bool) {
        updatedLikeIndex = index
        updatedLikeValue = isLiked
    }
    
    func reloadData() {
        didReloadData = true
    }
}
