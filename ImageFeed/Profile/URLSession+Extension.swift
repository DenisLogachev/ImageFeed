import Foundation

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[URLSession.data]: NetworkError.urlRequestError - \(error.localizedDescription)")
                    completion(.failure(NetworkError.urlRequestError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[URLSession.data]: NetworkError.urlSessionError - No HTTPURLResponse")
                    completion(.failure(NetworkError.urlSessionError))
                    return
                }
                
                guard let data = data else {
                    print("[URLSession.data]: NetworkError.emptyResponseData - No data received")
                    completion(.failure(NetworkError.emptyResponseData))
                    return
                }
                
                (200..<300).contains(httpResponse.statusCode)
                ? completion(.success(data))
                : {
                    print("[URLSession.data]: NetworkError.httpStatusCode - Code \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                }()
            }
        }
        
        task.resume()
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[objectTask]: DecodingError - \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "nil")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("[objectTask]: NetworkError - \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        return task
    }
}


