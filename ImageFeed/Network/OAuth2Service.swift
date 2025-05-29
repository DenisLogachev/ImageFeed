import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let session = URLSession.shared
    private let tokenURL = Constants.unsplashTokenURL
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    private let storage = OAuth2TokenStorage.shared
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if let currentTask = task {
            if lastCode == code {
                currentTask.cancel()
            } else {
                completion(.failure(NetworkError.anotherRequestInProgress))
                return
            }
        }
        
        lastCode = code
        guard let url = URL(string: Constants.unsplashTokenURL.absoluteString) else {
            print("[OAuth2Service.fetchOAuthToken]: NetworkError.invalidURL - Invalid token URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        guard let bodyData = bodyString.data(using: .utf8) else {
            print("[OAuth2Service.fetchOAuthToken]: NetworkError.invalidRequest - Failed to create request body")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        request.httpBody = bodyData
        
        task = session.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            self.task = nil
            self.lastCode = nil
            
            switch result {
            case .success(let response):
                self.storage.token = response.accessToken
                completion(.success(response.accessToken))
                
            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: NetworkError - \(error.localizedDescription), code: \(code)")
                completion(.failure(error))
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}
