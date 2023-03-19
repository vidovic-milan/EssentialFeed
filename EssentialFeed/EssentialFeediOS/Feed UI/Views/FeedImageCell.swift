import UIKit

public class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var locationContainer: UIStackView!
    @IBOutlet private(set) public var feedImageContainer: UIView!
    @IBOutlet private(set) public var feedImageView: UIImageView!
    @IBOutlet private(set) public var retryButton: UIButton!

    var onRetry: (() -> Void)?

    @IBAction private func retry() {
        onRetry?()
    }
}
