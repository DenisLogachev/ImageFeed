import Foundation
import UIKit

protocol ImagesListServiceProtocol: AnyObject {
    var photos: [Photo] { get }
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void)
    func clearPhotosList()
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private let session = URLSession.shared
    private var task: URLSessionTask?
    private var likeTask: URLSessionTask?
    private var lastLoadedPage: Int?
    private var _photos: [Photo] = []
    
    private let dateFormatter: ISO8601DateFormatter
    
    private init() {
        let formatter = ISO8601DateFormatter()
        self.dateFormatter = formatter
    }
    
    var photos: [Photo] {
        return _photos
    }
    
    func fetchPhotosNextPage() {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        var urlComponents = URLComponents(url: Constants.defaultBaseURL.appendingPathComponent("photos"), resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(nextPage)),
            URLQueryItem(name: "per_page", value: "10")
        ]
        
        guard let url = urlComponents.url else {
            print("[ImagesListService]: Failed to construct URL")
            return}
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        task = session.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let photoResults):
                let photoResults = photoResults.map { photoResult in
                    Photo(from: photoResult, dateFormatter: self.dateFormatter)
                }
                DispatchQueue.main.async {
                    let existingIds = Set(self.photos.map { $0.id })
                    let uniqueNewPhotos = photoResults.filter { !existingIds.contains($0.id) }
                    
                    if !uniqueNewPhotos.isEmpty {
                        self._photos.append(contentsOf: uniqueNewPhotos)
                        self.lastLoadedPage = nextPage
                        
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": uniqueNewPhotos]
                        )
                    }
                }
            case .failure(let error):
                print("[ImagesListService.fetchPhotosNextPage]: NetworkError - \(error.localizedDescription)")
            }
        }
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        likeTask?.cancel()
        
        let path = "/photos/\(photoId)/like"
        let url = Constants.defaultBaseURL.appendingPathComponent(path)
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        if let token = OAuth2TokenStorage.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        likeTask = session.objectTask(for: request) { [weak self] (result: Result<LikeResponse, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let likeResponse):
                let photoResult = likeResponse.photo
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoResult.id }) {
                        let oldPhoto = self.photos[index]
                        let newPhoto = Photo(from: photoResult, dateFormatter: self.dateFormatter)
                        self._photos = self.photos.withReplaced(safe: index, newValue: newPhoto)
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": [newPhoto]]
                        )
                        completion(.success(()))
                    } else {
                        completion(.success(()))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        likeTask?.resume()
    }
    
    func clearPhotosList() {
        _photos = []
        lastLoadedPage = nil
        NotificationCenter.default.post(
            name: ImagesListService.didChangeNotification,
            object: self,
            userInfo: ["photos": []]
        )
    }
}

extension ImagesListService: ImagesListServiceProtocol {
}

