import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    private let session = URLSession.shared
    private let tokenURL = Constants.unsplashTokenURL
    private var task: URLSessionTask?
    private var lastCode: String?
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        if lastCode == code { return }
        task?.cancel()
        lastCode = code
        guard let url = URL(string: Constants.unsplashTokenURL.absoluteString) else {
            print("Error: Invalid token URL")
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
        if let bodyData = bodyString.data(using: .utf8) {
            request.httpBody = bodyData
        } else {
            print("Error: Failed to create request body")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task = session.data(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    self.storage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    print("Decoding error: \(error)")
                    print("Response data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
                
            case .failure(let error):
                print("Network error: \(error)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}
