import Foundation

public class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession
	
	public init(session: URLSession = .shared) {
		self.session = session
	}
	
	private struct UnexpectedValuesRepresentation: Error {}

    private class TaskWrapper: HTTPClientTask {
        private weak var task: URLSessionDataTask?

        init(task: URLSessionDataTask) {
            self.task = task
        }

        func cancel() {
            task?.cancel()
            task = nil
        }

        func resume() {
            task?.resume()
        }
    }
	
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = TaskWrapper(task: session.dataTask(with: url) { data,    response, error in
                completion(
                    Result {
                        if let error = error {
                            throw error
                        } else if let data = data, let response = response as? HTTPURLResponse {
                            return (data, response)
                        } else {
                            throw UnexpectedValuesRepresentation()
                        }
                    }
                )
            }
        )
        task.resume()
        return task
	}
}
