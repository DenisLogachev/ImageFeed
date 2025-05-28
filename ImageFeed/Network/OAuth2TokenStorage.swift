import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let tokenKey = "OAuthToken"
    private init() {}  
    
    var token: String? {
        get {
            UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            if let value = newValue {
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            }
            else {
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
