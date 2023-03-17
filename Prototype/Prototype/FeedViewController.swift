import UIKit

struct FeedViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

class FeedViewController: UITableViewController {

    private var feed = [FeedViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
            self.feed = FeedViewModel.prototype
            self.tableView.reloadData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Feed Cell") as! FeedTableViewCell
        cell.configure(with: feed[indexPath.row])
        return cell
    }
}

extension FeedTableViewCell {
    func configure(with model: FeedViewModel) {
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil

        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil

        fadeIn(UIImage(named: model.imageName))
    }
}
