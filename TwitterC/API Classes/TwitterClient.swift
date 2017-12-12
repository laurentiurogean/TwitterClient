//
//  TwitterClient.swift
//  TwitterC
//
//  Created by Laurentiu Rogean on 24/10/2017.
//  Copyright © 2017 Laurentiu Rogean. All rights reserved.
//

import Foundation
import TwitterKit

class TwitterClient: NSObject {
    static let sharedInstance = TwitterClient()
    
    var twitterSession: TWTRSession?
    var userID: String?
    var userName: String?
    var name: String?
    var postsArray: [Post] = [ ]
    var profileBannerURL: URL?
    
    func verifySession() {
        if Twitter.sharedInstance().sessionStore.session() == nil {
            Twitter.sharedInstance().logIn(completion: { (session, error) in
                if let sess = session {
                    self.userID = sess.userID
                    self.userName = sess.userName
                    self.initializeFeedAndSettings()
                } else {
                    print("error: \(String(describing: error?.localizedDescription))");
                }
            })
            return
        } else {
            initializeFeedAndSettings()
        }
    }
    
    func initializeFeedAndSettings() {
        loadTweets()
        accountSettings()
        profileBanner()
    }
    
    func logOut() {
        let store = Twitter.sharedInstance().sessionStore
        
        if let userID = store.session()?.userID {
            store.logOutUserID(userID)
            postsArray.removeAll()
            NotificationCenter.default.post(name: NSNotification.Name("Posts"), object: nil)
            verifySession()
        }
    }
    
    // GET statuses/home_timeline.json
    func loadTweets() {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let statusesShowEndpoint = "https://api.twitter.com/1.1/statuses/home_timeline.json"
            let params = ["count": "70"]
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", url: statusesShowEndpoint, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    if let array = json as? [Any] {
                        self.postsArray.removeAll()
                        for obj in array {
                            let post = Post.init(dictionary: obj as! [String : Any])
                            self.postsArray.append(post)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name("Posts"), object: nil)
                    }
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
    }
    
    // GET account/verify_credentials.json
    func accountSettings() {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let url = "https://api.twitter.com/1.1/account/verify_credentials.json"
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "GET", url: url, parameters: nil, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                    if let array = json as? [String: Any] {
                        self.userName = array["screen_name"] as? String
                        self.name = array["name"] as? String
                    }
                } catch let jsonError as NSError {
                    print("json error: \(jsonError.localizedDescription)")
                }
            }
        }
    }
    
    // GET users/profile_image
    func profileBanner() {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            client.loadUser(withID: userID, completion: { (user, error) in
                self.profileBannerURL = URL(string: (user?.profileImageLargeURL)!)
            })
        }
    }
    
    func changeProfileBanner(encodedImage: String) {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let url = "https://api.twitter.com/1.1/account/update_profile_image.json"
            var clientError : NSError?
            let params = ["image": encodedImage]
            
            let request = client.urlRequest(withMethod: "POST", url: url, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
                
                self.profileBanner()
            }
        }
    }
    
    func postTweet(message: String) {
        if Twitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            let client = TWTRAPIClient.withCurrentUser()
            client.sendTweet(withText: message, completion: { (tweet, error) in
                if error != nil { print(error.debugDescription) }
                NotificationCenter.default.post(name: NSNotification.Name("Posts"), object: nil)
            })
        }
    }
    
    func changeDisplayedName(newName: String) {
        if let userID = Twitter.sharedInstance().sessionStore.session()?.userID {
            let client = TWTRAPIClient(userID: userID)
            let params = ["name": newName]
            let url = "https://api.twitter.com/1.1/account/update_profile.json"
            var clientError : NSError?
            
            let request = client.urlRequest(withMethod: "POST", url: url, parameters: params, error: &clientError)
            
            client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
                if connectionError != nil {
                    print("Error: \(String(describing: connectionError))")
                }
            }
        }
    }
    
}
