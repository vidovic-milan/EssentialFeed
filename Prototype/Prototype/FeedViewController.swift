import UIKit

struct FeedViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

class FeedViewController: UITableViewController {

    let feed = FeedViewModel.prototype

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Feed Cell") as! FeedTableViewCell
        cell.descriptionLabel.text = feed[indexPath.row].description
        cell.descriptionLabel.isHidden = feed[indexPath.row].description == nil

        cell.locationLabel.text = feed[indexPath.row].location
        cell.locationContainer.isHidden = feed[indexPath.row].location == nil

        cell.feedImageView.image = UIImage(named: feed[indexPath.row].imageName)
        return cell
    }
}

