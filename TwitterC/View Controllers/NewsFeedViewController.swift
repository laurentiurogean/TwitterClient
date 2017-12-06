//
//  FirstViewController.swift
//  TwitterC
//
//  Created by Laurentiu Rogean on 24/10/2017.
//  Copyright © 2017 Laurentiu Rogean. All rights reserved.
//

import UIKit
import TwitterKit

class NewsFeedViewController: UITableViewController, UITabBarControllerDelegate {
    
    @IBOutlet var newsFeedTableView: UITableView!
    var twitterClient: TwitterClient?
    private var posts: [Post] = []
    var refresher: UIRefreshControl = UIRefreshControl()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: Notification.Name("Posts"), object: nil)
        
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(refreshTweets), for: .valueChanged)
        
        newsFeedTableView.addSubview(refresher)
        
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if posts.isEmpty {
            TwitterClient.sharedInstance.verifySession()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("Posts"), object: nil)
    }
    
    // MARK: - UITableView business
    
    @objc func updateTable() {
        DispatchQueue.main.async {
            self.posts = TwitterClient.sharedInstance.postsArray
            
            self.newsFeedTableView.reloadData()
            self.refresher.endRefreshing()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TwitterClientTableViewCell.rowHeight()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = newsFeedTableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath)
        
        guard let message = posts[indexPath.row].text, let user = posts[indexPath.row].user?.screenName, let imageUrl = posts[indexPath.row].user?.imageUrl, let time = posts[indexPath.row].timeAgo, let name = posts[indexPath.row].user?.name else {
            return cell
        }
        
        if let tweetCell = cell as? TwitterClientTableViewCell {
            tweetCell.configureCell(username: user, name: name, tweet: message, imageUrl: imageUrl, timeAgo: time)
        }
        
        return cell
    }
    
    // MARK: - Twitter business
    
    @objc func refreshTweets() {
        TwitterClient.sharedInstance.verifySession()
    }
    
    @IBAction func newPost(_ sender: Any) {
        let composer = TWTRComposer()
        
        composer.setImage(UIImage(named: "twitterkit"))
     
        composer.show(from: self) { (result) in
            if (result == .done) {
                self.refreshTweets()
                print("Successfully composed Tweet.")
            } else {
                print("Cancelled composing.")
            }
        }
    }
    
    // MARK: - UITabBarDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        tableView.scrollToRow(at: IndexPath(row:0, section:0), at: .top, animated: true)
    }

}
