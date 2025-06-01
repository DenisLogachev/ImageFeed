import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private properties
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = oauth2TokenStorage.token {
            fetchProfileAndProceed()
        } else {
            showAuthScreen()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = UIColor(named: "BackgroundPrimary")
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "splash_screen_logo")
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Navigation
    private func showAuthScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            return
        }
        authVC.modalPresentationStyle = .fullScreen
        authVC.delegate = self
        present(authVC, animated: true, completion: nil)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {  print("Error: Failed to get window")
            return}
        guard let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController else {
            print("Error: Failed to instantiate TabBarController")
            return
        }
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
    
    // MARK: - Profile + Avatar loading
    private func fetchProfileAndProceed() {
        ProfileService.shared.fetchProfile { [weak self] result in
            switch result {
            case .success(let profile):
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { imageResult in
                    switch imageResult {
                    case .success(let url):
                        ProfileService.shared.updateAvatarURL(url)
                    case .failure(let error):
                        print("[SplashViewController]: Failed to fetch avatar URL: \(error.localizedDescription)")
                    }
                    DispatchQueue.main.async {
                        self?.switchToTabBarController()
                    }
                }
            case .failure(let error):
                print("[SplashViewController]: Failed to fetch profile: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Auth Delegate
extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) {
            self.fetchProfileAndProceed()
        }
    }
}

