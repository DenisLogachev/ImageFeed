import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    
    private let tokenKey = "OAuthToken"
    private init() {}
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                let isSuccess = KeychainWrapper.standard.set(newValue, forKey: tokenKey)
                if !isSuccess {
                    print("[OAuth2TokenStorage.token.set]: KeychainError.setFailed - Failed to save token")
                }
            }
            else {
                let removeSuccessful = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                if !removeSuccessful {
                    print("[OAuth2TokenStorage.token.remove]: KeychainError.removeFailed - Failed to remove token")
                }
            }
        }
    }
}

