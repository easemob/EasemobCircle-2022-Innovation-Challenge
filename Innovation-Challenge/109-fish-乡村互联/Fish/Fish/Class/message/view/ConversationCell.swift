//
//  ConversationCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/1.
//

import UIKit
import HyphenateChat
import Kingfisher

class ConversationCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var countView: UIView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var stateView: UserStatusView!
    
    private var downloadTask: DownloadTask?
    
    var conversation: EMConversation? {
        didSet {
            self.nameLabel.text = conversation?.conversationId
            self.iconImageView.image = UIImage(named: "head_placeholder")
            let unreadCount = conversation?.unreadMessagesCount ?? 0
            self.countView.isHidden = unreadCount <= 0
            self.countLabel.text = "\(unreadCount)"
        }
    }
    
    var userInfo: EMUserInfo? {
        didSet {
            self.downloadTask?.cancel()
            guard let userInfo = userInfo else {
                self.iconImageView.image = UIImage(named: "head_placeholder")
                return
            }
            self.nameLabel.text = userInfo.showname
            self.downloadTask = self.iconImageView.setImage(withUrl: userInfo.avatarUrl, placeholder: "head_placeholder")
        }
    }
    
    var state: UserStatusView.Status = .offline {
        didSet {
            self.stateView.status = self.state
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor(named: highlighted ? ColorName_242424 : ColorName_181818)
    }
}
