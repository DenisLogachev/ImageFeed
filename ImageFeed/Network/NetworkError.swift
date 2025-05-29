import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidURL
    case invalidRequest
    case emptyResponseData
    case anotherRequestInProgress
    case decodingError(Error)
    case noToken
}
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .httpStatusCode(let code):
            return "Сервер вернул ошибку: HTTP \(code)"
        case .urlRequestError(let error):
            return "Ошибка сети: \(error.localizedDescription)"
        case .urlSessionError:
            return "Произошла ошибка при выполнении запроса"
        case .invalidURL:
            return "Некорректный URL"
        case .invalidRequest:
            return "Невозможно создать запрос"
        case .emptyResponseData:
            return "Сервер вернул пустой ответ"
        case .anotherRequestInProgress:
            return "Запрос уже выполняется"
        case .decodingError(let error):
            return "Ошибка обработки ответа: \(error.localizedDescription)"
        case .noToken:
            return "Отсутствует токен авторизации"
        }
    }
}
