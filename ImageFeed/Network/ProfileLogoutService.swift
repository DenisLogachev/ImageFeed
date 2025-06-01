import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    func logout() {
        cleanCookies()
        cleanToken()
        cleanProfileData()
        switchToSplash()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }
    
    private func cleanToken() {
        OAuth2TokenStorage.shared.token = nil
    }
    
    private func cleanProfileData() {
        ProfileService.shared.clearProfile()
        ProfileImageService.shared.clearAvatarURL()
        ImagesListService.shared.clearPhotosList()
    }
    
    private func switchToSplash() {
        guard let window = UIApplication.shared.windows.first else {
            print("Error: No window")
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let splashVC = storyboard.instantiateViewController(withIdentifier: "SplashViewController") as? SplashViewController else {
            print("Error: Cannot instantiate SplashViewController")
            return
        }
        
        window.rootViewController = splashVC
        window.makeKeyAndVisible()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
