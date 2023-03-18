import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel<UIImage>

    init(feedImageViewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = feedImageViewModel
    }

    func view() -> FeedImageCell {
        let cell = FeedImageCell()
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.feedImageContainer.startShimmering()
        viewModel.onLoadedImage = { [weak cell] image in
            cell?.retryButton.isHidden = image != nil
            cell?.feedImageView.image = image
            cell?.feedImageContainer.stopShimmering()
        }
        cell.onRetry = { [weak viewModel] in
            viewModel?.loadImage()
        }
        viewModel.loadImage()

        return cell
    }

    func preload() {
        viewModel.preload()
    }

    func cancel() {
        viewModel.cancel()
    }
}
