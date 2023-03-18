import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel<UIImage>

    init(feedImageViewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = feedImageViewModel
    }

    func view() -> FeedImageCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImage()

        return cell
    }

    func preload() {
        viewModel.preload()
    }

    func cancel() {
        viewModel.cancel()
    }

    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.locationContainer.isHidden = viewModel.isLocationHidden

        viewModel.onLoadedImage = { [weak cell] image in
            cell?.feedImageView.image = image
        }

        viewModel.onShouldRetryChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }

        viewModel.onLoadingChange = { [weak cell] isLoading in
            if isLoading {
                cell?.feedImageContainer.startShimmering()
            } else {
                cell?.feedImageContainer.stopShimmering()
            }
        }

        cell.onRetry = { [weak viewModel] in
            viewModel?.loadImage()
        }

        return cell
    }
}
