import Foundation

protocol ProfileViewProtocol: AnyObject {
    func displayProfile(name: String, loginName: String, bio: String)
    func displayAvatar(url: URL?)
    func showLogoutConfirmation()
    func switchToSplash()
}


protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func didTapLogoutButton()
    func logoutConfirmed()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewProtocol?
    
    private let profileService: ProfileService
    private let logoutService: ProfileLogoutService
    
    init(profileService: ProfileService = .shared,
         logoutService: ProfileLogoutService = .shared) {
        self.profileService = profileService
        self.logoutService = logoutService
    }
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.displayProfile(name: profile.name,
                                 loginName: profile.loginName,
                                 bio: profile.bio ?? "")
            let url = URL(string: profile.profileImageURL)
            view?.displayAvatar(url: url)
        }
    }
    
    func didTapLogoutButton() {
        view?.showLogoutConfirmation()
    }
    
    func logoutConfirmed() {
        logoutService.logout()
        view?.switchToSplash()
    }
}
