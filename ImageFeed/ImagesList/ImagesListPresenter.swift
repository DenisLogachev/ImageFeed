import UIKit

protocol ImagesListViewProtocol: AnyObject {
    func updateTableAnimated(newPhotos: [Photo])
    func reloadData()
    func showLikeError()
    func showLoading()
    func hideLoading()
    func updateLikeState(at index: Int, isLiked: Bool)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var numberOfPhotos: Int { get }
    func viewDidLoad()
    func fetchNextPage()
    func photo(at index: Int) -> Photo
    func fullImageURL(at index: Int) -> URL?
    func toggleLike(at index: Int)
    var view: ImagesListViewProtocol? { get set }
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewProtocol?
    var imagesService: ImagesListServiceProtocol
    private var isLoading = false
    
    var numberOfPhotos: Int {
        imagesService.photos.count
    }
    
    var photos: [Photo] {
        imagesService.photos
    }
    
    init(view: ImagesListViewProtocol?, imagesService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.view = view
        self.imagesService = imagesService
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePhotosUpdate),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func viewDidLoad() {
        fetchNextPage()
    }
    
    func fetchNextPage() {
        guard !isLoading else { return }
        isLoading = true
        imagesService.fetchPhotosNextPage()
    }
    
    
    @objc private func didReceivePhotosUpdate(_ notification: Notification) {
        guard let newPhotos = notification.userInfo?["photos"] as? [Photo] else { return }
        
        isLoading = false
        if newPhotos.count == 1 || photos.isEmpty {
            view?.reloadData()
        } else {
            view?.updateTableAnimated(newPhotos: newPhotos)
        }
    }
    
    func photo(at index: Int) -> Photo {
        guard index >= 0 && index < photos.count else {
            fatalError("Index out of range")
        }
        return photos[index]
    }
    
    func fullImageURL(at index: Int) -> URL? {
        guard index >= 0 && index < photos.count else { return nil }
        return URL(string: photos[index].fullImageURL)
    }
    
    func toggleLike(at index: Int) {
        let photo = photos[index]
        
        view?.showLoading()
        UIBlockingProgressHUD.show()
        
        imagesService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                self.view?.hideLoading()
                
                switch result {
                case .success:
                    self.view?.updateLikeState(at: index, isLiked: !photo.isLiked)
                    self.view?.reloadData()
                case .failure:
                    self.view?.showLikeError()
                }
            }
        }
    }
}
