import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    private let tableView = UITableView()
    private var photos: [Photo] {
        ImagesListService.shared.photosList
    }
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private var isLoading = false
    
    private let dateFormatter: DateFormatter
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        self.dateFormatter = formatter
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        self.dateFormatter = formatter
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupObservers()
        fetchPhotos()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.backgroundColor = UIColor(named: "BackgroundPrimary")
        tableView.separatorStyle = .none
        tableView.accessibilityIdentifier = "ImagesListTable"
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePhotosUpdate),
            name: ImagesListService.didChangeNotification,
            object: nil
        )
    }
    
    private func fetchPhotos() {
        guard !isLoading else { return }
        isLoading = true
        ImagesListService.shared.fetchPhotosNextPage()
    }
    
    @objc private func didReceivePhotosUpdate(_ notification: Notification) {
        guard let newPhotos = notification.userInfo?["photos"] as? [Photo] else { return }
        
        DispatchQueue.main.async {
            self.isLoading = false
            self.updateTableViewAnimated(newPhotos: newPhotos)
        }
    }
    
    private func updateTableViewAnimated(newPhotos: [Photo]) {
        if newPhotos.count == 1 || self.photos.isEmpty {
            self.tableView.reloadData()
            return
        }
        
        let oldCount = self.photos.count - newPhotos.count
        let newCount = self.photos.count
        
        if newCount > oldCount {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else { return }
            
            let photo = ImagesListService.shared.photosList[indexPath.row]
            if let url = URL(string: photo.fullImageURL) {
                viewController.imageURL = url
            }
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

// MARK: - UITableViewDataSource
extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ImagesListService.shared.photosList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ImagesListCell.reuseIdentifier,
            for: indexPath
        ) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        let photo = ImagesListService.shared.photosList[indexPath.row]
        cell.configure(with: photo, dateFormatter: dateFormatter)
        cell.accessibilityLabel = "Фотография \(indexPath.row + 1)"
        cell.delegate = self
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let scale = imageViewWidth / photo.size.width
        let height = photo.size.height * scale + imageInsets.top + imageInsets.bottom
        return height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            fetchPhotos()
        }
    }
}


extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        
        ImagesListService.shared.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success:
                    if let updatedPhoto = ImagesListService.shared.photosList.first(where: { $0.id == photo.id }) {
                        cell.setIsLiked(updatedPhoto.isLiked)
                    }
                case .failure:
                    let alert = UIAlertController(
                        title: "Ошибка",
                        message: "Не удалось поставить лайк",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "ОК", style: .default))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
