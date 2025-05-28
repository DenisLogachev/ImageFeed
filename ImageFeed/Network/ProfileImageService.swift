import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    static let shared = ProfileImageService()
    private init() {}
    
    private var task: URLSessionTask?
    private let session = URLSession.shared
    private(set) var avatarURL: String?
    
    private struct UserResult: Codable {
        let profileImage: ProfileImage
        
        enum CodingKeys: String, CodingKey {
            case profileImage = "profile_image"
        }
        
        struct ProfileImage: Codable {
            let small: String
        }
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()
        
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService.fetchProfileImageURL]: NetworkError.noToken - No token available")
            completion(.failure(NetworkError.noToken))
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService.fetchProfileImageURL]: NetworkError.invalidURL - Invalid URL for username: \(username)")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        task = session.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.task = nil
                switch result {
                case .success(let userResult):
                    let imageURL = userResult.profileImage.small
                    self.avatarURL = imageURL
                    NotificationCenter.default.post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": imageURL])
                    completion(.success(imageURL))
                    
                case .failure(let error):
                    print("[ProfileImageService.fetchProfileImageURL]: NetworkError - \(error.localizedDescription) for username: \(username)")
                    completion(.failure(error))
                }
            }
        }
        
        task?.resume()
    }
}

