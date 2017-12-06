//
//  User.swift
//  TwitterC
//
//  Created by Laurentiu Rogean on 24/10/2017.
//  Copyright © 2017 Laurentiu Rogean. All rights reserved.
//

import Foundation

class User {
    var screenName: String?
    var name: String?
    var imageUrl: String?
    
    init(dictionary: [String: Any]) {
        if let screenName = dictionary["screen_name"] as? String {
            self.screenName = screenName
        }
        
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        
        if let urlString = dictionary["profile_image_url"] as? String {
            imageUrl = urlString
        }
    }
    
}
