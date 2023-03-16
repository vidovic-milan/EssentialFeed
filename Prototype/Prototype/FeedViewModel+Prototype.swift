import Foundation

extension FeedViewModel {
    static var prototype: [FeedViewModel] {
        [
            .init(description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.", location: "Garth Pier North Wales", imageName: "image-1"),
            .init(description: nil, location: "Garth Pier\north Wales", imageName: "image-1"),
            .init(description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.", location: nil, imageName: "image-1"),
            .init(description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.", location: "Garth Pier\nNorth Wales", imageName: "image-1"),
            .init(description: nil, location: nil, imageName: "image-1"),
            .init(description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.", location: "Garth Pier\nNorth Wales", imageName: "image-1")
        ]
    }
}
