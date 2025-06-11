import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let fullImageURL: String
    let isLiked: Bool
    
    init(from result: PhotoResult, dateFormatter: ISO8601DateFormatter) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt.flatMap { dateFormatter.date(from: $0) }
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.fullImageURL = result.urls.full
        self.isLiked = result.likedByUser
    }
    
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, fullImageURL: String, isLiked: Bool) {
        self.id = id
        self.size = size
        self.createdAt = createdAt
        self.welcomeDescription = welcomeDescription
        self.thumbImageURL = thumbImageURL
        self.fullImageURL = fullImageURL
        self.isLiked = isLiked
    }
    
    static func == (lhs: Photo, rhs: Photo) -> Bool {
        lhs.id == rhs.id &&
        lhs.size == rhs.size &&
        lhs.createdAt == rhs.createdAt &&
        lhs.welcomeDescription == rhs.welcomeDescription &&
        lhs.thumbImageURL == rhs.thumbImageURL &&
        lhs.fullImageURL == rhs.fullImageURL &&
        lhs.isLiked == rhs.isLiked
    }
}


