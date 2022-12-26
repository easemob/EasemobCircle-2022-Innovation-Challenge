//
//  MessageThreadView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/27.
//

import UIKit
import HyphenateChat

class MessageThreadView: UIView {

    @IBOutlet private weak var threadNameLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var unreadCountLabel: UILabel!
    
    var clickHandle: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selfInit()
    }
    
    private func selfInit() {
        EMClient.shared().threadManager?.add(self, delegateQueue: nil)
    }
    
    var thread: EMChatThread? {
        didSet {
            self.threadNameLabel.text = thread?.threadName
            guard let threadId = thread?.threadId else {
                return
            }
            if let count = self.thread?.messageCount, count > 0 {
                self.unreadCountLabel.text = count > 99 ? "99+" : "\(count)"
            } else {
                self.unreadCountLabel.text = nil
            }
            
            var lastMessage = self.thread?.lastMessage
            if lastMessage == nil {
                if let conversation = EMClient.shared().chatManager?.getConversation(threadId, type: .groupChat, createIfNotExist: false, isThread: true) {
                    lastMessage = conversation.latestMessage
                }
            }
            self.message = lastMessage
        }
    }
    
    private var message: EMChatMessage? {
        didSet {
            guard let message = self.message else {
                self.iconImageView.image = nil
                self.usernameLabel.text = nil
                self.timeLabel.text = nil
                self.messageLabel.text = "暂无消息"
                return
            }
            UserInfoManager.share.queryUserInfo(userId: message.from, loadCache: true) { userInfo, _ in
                guard self.message?.from == userInfo?.userId else {
                    return
                }
                self.iconImageView.setImage(withUrl: userInfo?.avatarUrl, placeholder: "head_placeholder")
                self.usernameLabel.text = userInfo?.showname
            }
            self.messageLabel.text = message.threadShowText()
            self.timeLabel.text = self.durationString(timeStamp: TimeInterval(message.timestamp))
        }
    }
    
    @IBAction func clickAction() {
        self.clickHandle?()
    }
    
    private func durationString(timeStamp: TimeInterval) -> String {
        if timeStamp <= 0 {
            return ""
        }
        // 当前时间
        let ago = Date(timeIntervalSince1970: timeStamp / 1000.0)
        let current = Date()
        let calendar = Calendar.current
        let years = calendar.component(.year, from: current) - calendar.component(.year, from: ago)
        if years >= 1 {
            return "\(years)年前"
        }
        let months = calendar.component(.month, from: current) - calendar.component(.month, from: ago)
        if months >= 1 && months < 12 {
            return "\(months)个月前"
        }
        let weeks = calendar.component(.weekOfMonth, from: current) - calendar.component(.weekOfMonth, from: ago)
        if weeks >= 1 && months < 1 {
            return "\(weeks)周前"
        }
        let days = calendar.component(.day, from: current) - calendar.component(.day, from: ago)
        if days < 7 && days >= 1 {
            return "\(days)天前"
        }
        let hours = calendar.component(.hour, from: current) - calendar.component(.hour, from: ago)
        if hours >= 1 && hours < 24 {
            return "\(hours)小时前"
        }
        let minutes = calendar.component(.minute, from: current) - calendar.component(.minute, from: ago)
        if minutes >= 1 && minutes < 60 {
            return "\(minutes)分钟前"
        }
        let seconds = calendar.component(.second, from: current) - calendar.component(.second, from: ago)
        if seconds < 60 && minutes < 1 {
            return "1分钟前"
        }
        return "刚刚"
    }
    
    var viewHeight: CGFloat {
        if self.thread == nil {
            return 0
        } else if self.message == nil {
            return 65
        } else {
            return 98
        }
    }
    
    deinit {
        EMClient.shared().threadManager?.remove(self)
    }
}

extension MessageThreadView: EMThreadManagerDelegate {
    func onChatThreadUpdate(_ event: EMChatThreadEvent) {
        if self.thread?.threadId == event.chatThread.threadId {
            self.threadNameLabel.text = event.chatThread.threadName
        }
    }
}
