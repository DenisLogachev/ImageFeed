import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewProtocol {
    private var presenter: ProfilePresenterProtocol?
    
    var nameLabel: UILabel?
    var loginNameLabel: UILabel?
    var descriptionLabel: UILabel?
    var avatarImageView: UIImageView?
    var logoutButton: UIButton?
    
    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "BackgroundPrimary")
        setupUI()
        guard let presenter = presenter else {
            assertionFailure("Presenter is nil")
            return
        }
        presenter.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let avatarImageView {
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        }
    }
    
    
    // MARK: - ProfileViewProtocol
    func displayProfile(name: String, loginName: String, bio: String) {
        nameLabel?.text = name
        loginNameLabel?.text = loginName
        descriptionLabel?.text = bio
    }
    
    func displayAvatar(url: URL?) {
        if let url = url {
            avatarImageView?.kf.setImage(
                with: url,
                placeholder: placeholderAvatarImage(),
                options: [
                    .transition(.fade(0.3)),
                    .cacheOriginalImage
                ]
            )
        } else {
            avatarImageView?.image = placeholderAvatarImage()
        }
    }
    
    
    func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel)
        let confirmAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            guard let presenter = self?.presenter else { return }
            presenter.logoutConfirmed()
        }
        confirmAction.accessibilityIdentifier = "Yes"
        
        alert.addAction(cancelAction)
        alert.addAction(confirmAction)
        alert.view.accessibilityIdentifier = "LogoutAlert"
        present(alert, animated: true)
    }
    
    func switchToSplash() {
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
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: nil,
            completion: nil
        )
    }
    
    // MARK: - UI Setup
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
        imageView.accessibilityIdentifier = "ProfileAvatar"
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
        label.accessibilityIdentifier = "Name"
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
        label.accessibilityIdentifier = "Login"
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
        label.accessibilityIdentifier = "ProfileBio"
        view.addSubview(label)
        descriptionLabel = label
    }
    
    // Logout Button
    private func setupLogoutButton() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "logout_button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapLogoutButton), for: .touchUpInside)
        button.accessibilityIdentifier = "Logout"
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
    
    private func placeholderAvatarImage() -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: 70, weight: .regular)
        let image = UIImage(systemName: "person.crop.circle.fill", withConfiguration: config)
        return image?.withTintColor(UIColor(named: "TextSecondary") ?? .gray, renderingMode: .alwaysOriginal)
    }
    
    // MARK: - Actions
    @objc func didTapLogoutButton() {
        guard let presenter = presenter else {
            assertionFailure("Presenter is nil")
            return
        }
        presenter.didTapLogoutButton()
    }
}


