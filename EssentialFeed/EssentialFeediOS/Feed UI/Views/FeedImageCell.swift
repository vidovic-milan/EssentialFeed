import UIKit

public class FeedImageCell: UITableViewCell {
    public let descriptionLabel = UILabel()
    public let locationLabel = UILabel()
    public let locationContainer = UIStackView()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)
        return button
    }()

    var onRetry: (() -> Void)?

    @objc private func retry() {
        onRetry?()
    }
}
