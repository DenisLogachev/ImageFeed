import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request) { data, response, error in
            if let data = data,
               let response = response as? HTTPURLResponse {
                if (200..<300).contains(response.statusCode) {
                    fulfillCompletionOnMainThread(.success(data))
                } else {
                    print("Error: HTTP status code \(response.statusCode)")
                    fulfillCompletionOnMainThread(.failure(NetworkError.httpStatusCode(response.statusCode)))
                }
            } else if let error = error {
                print("Error: URL request failed - \(error.localizedDescription)")
                fulfillCompletionOnMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                print("Error: Unknown URL session error")
                fulfillCompletionOnMainThread(.failure(NetworkError.urlSessionError))
            }
        }
        
        return task
    }
}
