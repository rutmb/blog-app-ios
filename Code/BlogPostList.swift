//
//  BlogPostList.swift
//  Blog
//
//  Created by Boris Bügling on 22/01/15.
//  Copyright (c) 2015 Contentful GmbH. All rights reserved.
//

import UIKit

class BlogPostListCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:.Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        textLabel?.frame.origin.y = 0.0
        textLabel?.frame.size.height = 55.0
        detailTextLabel?.frame.origin.y = (textLabel?.frame.maxY)!
    }
}

class BlogPostList: UITableViewController {
    var dataManager: ContentfulDataManager?
    var dataSource: CoreDataFetchDataSource?
    var metadataViewController: PostListMetadataViewController!
    var predicate: String?
    var showsAuthor: Bool = true

    func refresh() {
        dataManager?.performSynchronization({ (error) -> Void in
            if error != nil && error.code != NSURLErrorNotConnectedToInternet {
                let alert = UIAlertView(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: ""))
                alert.show()
            }

            self.dataSource?.performFetch()
        })
    }

    func showMetadataHeader() {
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)

        metadataViewController = storyboard?.instantiateViewControllerWithIdentifier(ViewControllerStoryboardIdentifier.AuthorViewControllerId.rawValue) as PostListMetadataViewController
        metadataViewController.client = dataManager?.client
        metadataViewController.view.autoresizingMask = .None
        metadataViewController.view.frame.size.height = 160.0

        tableView.tableHeaderView = metadataViewController.view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        addInfoButton()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)

        dataManager = ContentfulDataManager()

        let controller = dataManager?.fetchedResultsControllerForContentType(ContentfulDataManager.PostContentTypeId, predicate: predicate, sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)])
        let tableView = self.tableView!
        dataSource = CoreDataFetchDataSource(fetchedResultsController: controller, tableView: tableView, cellIdentifier: NSStringFromClass(BlogPostList.self))

        dataSource?.cellConfigurator = { (cell, indexPath) -> Void in
            if let tcell = cell as? UITableViewCell {
                tcell.accessoryType = .DisclosureIndicator
                tcell.detailTextLabel?.font = UIFont.bodyTextFont().fontWithSize(12.0)
                tcell.detailTextLabel?.textColor = UIColor.contentfulDeactivatedColor()
                tcell.selectionStyle = .None
                tcell.textLabel?.font = UIFont.titleBarFont()
                tcell.textLabel?.numberOfLines = 2

                if tcell.respondsToSelector("setLayoutMargins:") {
                    tcell.layoutMargins = UIEdgeInsetsZero
                    tcell.preservesSuperviewLayoutMargins = false
                }

                if let post = self.dataSource?.objectAtIndexPath(indexPath) as? Post {
                    tcell.textLabel?.text = post.title

                    if let date = post.date {
                        let authorString = post.author != nil ? NSLocalizedString("by ", comment: "") + ((post.author!.array as NSArray).valueForKey("name") as NSArray).componentsJoinedByString(", ") : NSLocalizedString("Unknown", comment: "Unknown author")
                        let dateString = NSDateFormatter.customDateFormatter().stringFromDate(date)
                        tcell.detailTextLabel?.text = String(format:"%@. %@", dateString.uppercaseString, self.showsAuthor ? authorString : "")
                    }
                }
            }
        }

        tableView.dataSource = dataSource
        tableView.rowHeight = 80.0
        tableView.separatorInset = UIEdgeInsetsZero

        tableView.registerClass(BlogPostListCell.self, forCellReuseIdentifier: NSStringFromClass(BlogPostList.self))
    }

    override func viewWillAppear(animated: Bool) {
        refresh()
    }

    // MARK: UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let post = self.dataSource?.objectAtIndexPath(indexPath) as? Post {
            let identifier = ViewControllerStoryboardIdentifier.BlogPostViewControllerId.rawValue
            let blogPostViewController = storyboard?.instantiateViewControllerWithIdentifier(identifier) as? BlogPostViewController
            blogPostViewController?.client = dataManager?.client
            blogPostViewController?.post = post

            navigationController?.pushViewController(blogPostViewController!, animated: true)
        }
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if metadataViewController != nil {
            metadataViewController.numberOfPosts = tableView.numberOfRowsInSection(0)
        }
    }
}
