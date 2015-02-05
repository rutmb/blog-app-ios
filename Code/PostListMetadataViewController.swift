//
//  PostListMetadataViewController.swift
//  Blog
//
//  Created by Boris Bügling on 02/02/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

struct PostListMetadata {
    let body: String?
    let photo: Asset?
    let title: String?
}

class PostListMetadataViewController: UIViewController {
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var numberOfPostLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    weak var client: CDAClient!
    var metadata: PostListMetadata! = nil {
        didSet {
            bodyLabel.text = metadata.body
            imageView.offlineCaching_cda = true
            imageView.cda_setImageWithPersistedAsset(metadata.photo, client: client, size: imageView.frame.size, placeholderImage: nil)
            titleLabel.text = metadata.title
        }
    }
    var numberOfPosts: Int {
        get { return 0 }
        set {
            numberOfPostLabel.text = String(format: "%d posts by %@", newValue, metadata.title!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bodyLabel.font = UIFont.bodyTextFont().fontWithSize(13.0)
        bodyLabel.textColor = UIColor.contentfulDeactivatedColor()
        titleLabel.font = UIFont.boldTitleFont()
        numberOfPostLabel.font = UIFont.bodyTextFont()
    }
}
