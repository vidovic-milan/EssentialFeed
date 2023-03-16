import UIKit

class FeedTableViewCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()
        feedImageView.alpha = 0
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        feedImageView.alpha = 0
    }

    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        UIView.animate(withDuration: 1, delay: 0.5, options: .layoutSubviews) { [weak self] in
            self?.feedImageView.alpha = 1
        }
    }
}
