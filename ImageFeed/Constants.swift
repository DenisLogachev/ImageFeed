import Foundation

enum Constants {
    static let accessKey = "yl8LsFDwpAJzZkEQ6lZ-pgHi4Dn8FHJv3XvnN5IbZK8"
    static let secretKey = "UBGtzynLoIM7NbWtmsvNvQttLT6e5oWe3rAxCE175jA"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Failed to create defaultBaseURL")
        }
        return url
    }()
    
    static let unsplashTokenURL: URL = {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            fatalError("Failed to create unsplashTokenURL")
        }
        return url
    }()
}
