import Foundation

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// Completion can be invoked on any queue
    /// Clients are responsible to dispatch to appropriate thread, if needed.
	func get(from url: URL, completion: @escaping (Result) -> Void)
}
