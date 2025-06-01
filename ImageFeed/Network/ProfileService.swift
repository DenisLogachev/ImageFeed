import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var profileTask: URLSessionTask?
    
    private(set) var profile: Profile?

    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        profileTask?.cancel()
        
        guard let request = makeMeRequest() else {
            print("[ProfileService.fetchProfile]: NetworkError.invalidRequest - Failed to create /me request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        profileTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    let profile = Profile(
                        username: profileResult.username,
                        name: "\(profileResult.firstName) \(profileResult.lastName)",
                        loginName: "@\(profileResult.username)",
                        bio: profileResult.bio,
                        profileImageURL: ""
                    )
                    self?.profile = profile
                    print("[ProfileService.fetchProfile]: Profile loaded: \(profile.username)")
                    completion(.success(profile))
                    
                case .failure(let error):
                    print("[ProfileService.fetchProfile]: NetworkError - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        
        profileTask?.resume()
    }
    func updateAvatarURL(_ url: String) {
        guard var currentProfile = profile else {
            print("[ProfileService.updateAvatarURL]: No profile to update")
            return
        }
        currentProfile.profileImageURL = url
        profile = currentProfile
        print("[ProfileService.updateAvatarURL]: Avatar URL updated")
    }
    
    func makeMeRequest() -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token,
              let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clearProfile() {
        profile = nil
    }
    
}

