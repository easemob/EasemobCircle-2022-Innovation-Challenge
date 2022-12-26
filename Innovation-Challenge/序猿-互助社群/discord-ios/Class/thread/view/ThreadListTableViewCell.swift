//
//  ThreadListTableViewCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/13.
//

import UIKit
import HyphenateChat

class ThreadListTableViewCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var msgLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    var chatThread: EMChatThread? {
        didSet {
            self.nameLabel.text = self.chatThread?.threadName
        }
    }
    
    var lastMessage: EMChatMessage? {
        didSet {
            guard let lastMessage = lastMessage else {
                self.msgLabel.text = "抱歉，无法加载原始消息"
                self.usernameLabel.text = nil
                self.timeLabel.text = nil
                self.iconImageView.image = nil
                return
            }

            if let userInfo = UserInfoManager.share.userInfo(userId: lastMessage.from) {
                self.usernameLabel.text = userInfo.showname
                self.iconImageView.setImage(withUrl: userInfo.avatarUrl, placeholder: "head_placeholder")
            } else {
                self.usernameLabel.text = lastMessage.from
                self.iconImageView.image = UIImage(named: "head_placeholder")
            }

            self.msgLabel.text = lastMessage.showText()
            let now = Int64(Date().timeIntervalSince1970)
            let messageTimestamp = lastMessage.timestamp / 1000
            if messageTimestamp > now || lastMessage.timestamp <= 0 {
                self.timeLabel.text = ""
            } else {
                let v = now - messageTimestamp
                if v < 60 {
                    self.timeLabel.text = "刚刚"
                } else if v < 60 * 60 {
                    self.timeLabel.text = "\(v / 60)分钟前"
                } else if v < 60 * 60 * 24 {
                    self.timeLabel.text = "\(v / 60 / 60)小时前"
                } else {
                    self.timeLabel.text = "\(v / 60 / 60 / 24)天前"
                }
            }
        }
    }
}
