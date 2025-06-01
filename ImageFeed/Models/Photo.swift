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
}


