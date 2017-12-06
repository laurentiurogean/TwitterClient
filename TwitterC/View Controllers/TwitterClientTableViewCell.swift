//
//  TwitterClientTableViewCell.swift
//  TwitterC
//
//  Created by Laurentiu Rogean on 01/11/2017.
//  Copyright © 2017 Laurentiu Rogean. All rights reserved.
//

import UIKit
import SDWebImage
import TTTAttributedLabel

class TwitterClientTableViewCell: UITableViewCell, TTTAttributedLabelDelegate {

    static let kIconHeight: CGFloat = 40.0
    static let topPadding: CGFloat = 5.0
    static let bottomPadding: CGFloat = 15.0
    
    
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var tweetView: UIView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    var tweetLabel: TTTAttributedLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        tweetLabel = TTTAttributedLabel.init(frame: .zero)
        tweetLabel.numberOfLines = 4
        tweetLabel.lineBreakMode = .byWordWrapping
        tweetLabel.font = UIFont.systemFont(ofSize: 12)
        tweetLabel.textColor = .black
        tweetLabel.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        tweetLabel.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !(tweetLabel.superview == tweetView) {
            tweetLabel.frame = tweetView.bounds
            tweetView.addSubview(tweetLabel)
        }
    }
    
    func configureCell(username: String, name: String, tweet: String, imageUrl: String, timeAgo: String) {
        self.username.text = "@" + username
        tweetLabel.text = tweet
        timeAgoLabel.text = timeAgo
        nameLabel.text = name
        
        
        // Configure avatar
        self.avatar.layer.cornerRadius = 20
        self.avatar.layer.borderWidth = 1
        self.avatar.layer.borderColor = tintColor.cgColor
        self.avatar.layer.masksToBounds = true
        self.avatar.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "placeholderavatar"))
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    static func rowHeight() -> CGFloat {
        return kIconHeight + topPadding + bottomPadding + 74.0
    }
}

