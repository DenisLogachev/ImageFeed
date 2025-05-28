import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    private var nameLabel: UILabel?
    private var loginNameLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var avatarImageView: UIImageView?
    private var logoutButton: UIButton?
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundPrimary")
        setupUI()
        
        if let profile = ProfileService.shared.profile {
            updateUI(with: profile)
        }
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let avatarImageView {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        }
    }
    private func setupUI() {
        setupAvatarImageView()
        setupNameLabel()
        setupLoginNameLabel()
        setupDescriptionLabel()
        setupLogoutButton()
        setupConstraints()
    }
    
    // Avatar
    private func setupAvatarImageView() {
        let imageView = UIImageView()
        imageView.image = placeholderAvatarImage()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        view.addSubview(imageView)
        avatarImageView = imageView
    }
    
    // Name Label
    private func setupNameLabel() {
        let label = UILabel()
        label.text = "Ирина Новикова"
        label.textColor = UIColor(named: "TextPrimary")
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        nameLabel = label
    }
    
    // Login Name Label
    private func setupLoginNameLabel() {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.textColor = UIColor(named: "TextSecondary")
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        loginNameLabel = label
    }
    
    // Description Label
    private func setupDescriptionLabel() {
        let label = UILabel()
        label.text = "Hello, World!"
        label.textColor = UIColor(named: "TextPrimary")
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        descriptionLabel = label
    }
    
    // Logout Button
    private func setupLogoutButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        view.addSubview(button)
        logoutButton = button
    }
    
    // Constraints
    private func setupConstraints() {
        guard let avatarImageView,
              let nameLabel,
              let loginNameLabel,
              let descriptionLabel,
              let logoutButton else { return }
        
        NSLayoutConstraint.activate([
            avatarImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            avatarImageView.widthAnchor.constraint(equalToConstant: 70),
            avatarImageView.heightAnchor.constraint(equalToConstant: 70),
            
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            
            loginNameLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loginNameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            
            descriptionLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginNameLabel.bottomAnchor, constant: 8),
            
            
            logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            logoutButton.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func updateUI(with profile: Profile) {
        nameLabel?.text = profile.name
        loginNameLabel?.text = profile.loginName
        descriptionLabel?.text = profile.bio
        updateAvatar()
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileService.shared.profile?.profileImageURL,
            let url = URL(string: profileImageURL)
        else {
            avatarImageView?.image = placeholderAvatarImage()
            return }
        avatarImageView?.kf.setImage(
            with: url,
            placeholder: placeholderAvatarImage(),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        )
    }
    
    private func placeholderAvatarImage() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .regular)
        let image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        return image?.withTintColor(UIColor(named: "TextSecondary") ?? .gray, renderingMode: .alwaysOriginal)
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc
    private func didTapLogoutButton() {
        print ("Logout tapped")
        OAuth2TokenStorage.shared.token = nil
        switchToSplash()
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


