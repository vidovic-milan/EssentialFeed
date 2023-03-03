import Foundation

public class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    private struct UnexpectedResponseError: Error {}

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get(from url: URL, completion: @escaping (HTTPClientResponse) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(response, data))
            } else {
                completion(.failure(UnexpectedResponseError()))
            }
        }.resume()
    }
}
