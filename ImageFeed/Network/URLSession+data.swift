import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: URL request failed - \(error.localizedDescription)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Error: Unknown URL session error (no HTTP response)")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                guard let data = data else {
                    print("Error: Response has no data")
                    completion(.failure(NetworkError.emptyResponseData))
                    return
                }
                
                (200..<300).contains(httpResponse.statusCode)
                ? completion(.success(data))
                : {
                    print("Error: HTTP status code \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }()
            }
        }
        
        task.resume()
        return task
    }
}

