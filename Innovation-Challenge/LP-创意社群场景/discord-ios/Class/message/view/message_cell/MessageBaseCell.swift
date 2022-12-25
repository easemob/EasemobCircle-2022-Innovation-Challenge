//
//  MessageBaseCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/4.
//

import UIKit
import SnapKit
import Kingfisher
import HyphenateChat

class MessageBaseCell: UITableViewCell {
    
    private let commonView: MessageCommonView
    private let reactionView = MessageReactionListView()
    private let threadView: MessageThreadView
    
    var didLongPressHandle: ((_ message: EMChatMessage) -> Void)?
    var didSelectedReaction: ((_ message: EMChatMessage, _ reaction: EMMessageReaction) -> Void)?
    var didClickAddReaction: ((_ message: EMChatMessage) -> Void)?
    var didClickHeadHandle: ((_ message: EMChatMessage) -> Void)?
    var didClickThreadHandle: ((_ message: EMChatMessage) -> Void)?
    
    var showReaction = true
    var showThread = true
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        self.commonView = Bundle.main.loadNibNamed("MessageCommonView", owner: nil)!.first as! MessageCommonView
        self.threadView = Bundle.main.loadNibNamed("MessageThreadView", owner: nil)!.first as! MessageThreadView
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.contentView.addSubview(self.commonView)
        self.contentView.addSubview(self.reactionView)
        self.contentView.addSubview(self.threadView)
        self.selectionStyle = .none
        self.commonView.clickHeadHandle = { [unowned self] in
            if let message = message {
                self.didClickHeadHandle?(message)
            }
        }
        self.commonView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
        }
        self.threadView.clickHandle = { [unowned self] in
            if let message = self.message {
                self.didClickThreadHandle?(message)
            }
        }
        self.reactionView.didSelectedReaction = { [unowned self] message, reaction in
            self.didSelectedReaction?(message, reaction)
        }
        self.reactionView.didClickEmoji = { [unowned self] message in
            self.didClickAddReaction?(message)
        }
        self.reactionView.snp.makeConstraints { make in
            make.top.equalTo(self.commonView.snp.bottom)
            make.height.equalTo(0)
            make.left.right.equalTo(self.commonView.containerView)
        }
        self.threadView.snp.makeConstraints { make in
            make.top.equalTo(self.reactionView.snp.bottom)
            make.height.equalTo(0)
            make.bottom.equalTo(0)
            make.left.right.equalTo(self.commonView.containerView)
        }
        self.setupContentView(self.commonView.containerView)
        
        let longPressGes = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        self.contentView.addGestureRecognizer(longPressGes)
        
        //整蛊
        NotificationCenter.default.addObserver(self, selector: #selector(onPrankNotify), name: NSNotification.Name(rawValue: "PRANK-Notify"), object: nil)
        
    }
    @objc func onPrankNotify(_ notify: NSNotification) {
        let ID = notify.object as? String
        let from = message?.from
        if ID == from {
            self.commonView.onPrank()
        } else {
            self.commonView.onStopPrank()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var message: EMChatMessage? {
        didSet {
            if let from = message?.from, let userInfo = UserInfoManager.share.userInfo(userId: from) {
                self.commonView.iconImageView.setImage(withUrl: userInfo.avatarUrl, placeholder: "head_placeholder")
                self.commonView.nameLabel.text = userInfo.showname
            } else {
                self.commonView.iconImageView.setImage(withUrl: nil, placeholder: "head_placeholder")
                self.commonView.nameLabel.text = message?.from
                if let userId = message?.from {
                    UserInfoManager.share.queryUserInfo(userId: userId, loadCache: false) { userInfo, _ in
                        if let userInfo = userInfo, self.message?.from == userInfo.userId {
                            self.commonView.iconImageView.setImage(withUrl: userInfo.avatarUrl, placeholder: "head_placeholder")
                            self.commonView.nameLabel.text = userInfo.showname
                        }
                    }
                }
            }
            
            if let time = message?.timestamp {
                let dataFormatter = DateFormatter()
                dataFormatter.dateFormat = "MM月dd日 HH:mm"
                let date = Date(timeIntervalSince1970: TimeInterval(time / 1000))
                self.commonView.timeLabel.text = dataFormatter.string(from: date)
            } else {
                self.commonView.timeLabel.text = nil
            }
            self.update(message)
            self.layoutIfNeeded()   // 防止未布局导致reaction视图宽度为0
            if let message = message, self.showReaction {
                self.reactionView.setMessage(message)
                self.reactionView.snp.updateConstraints { make in
                    make.height.equalTo(self.reactionView.maxHeight)
                }
            } else {
                self.reactionView.snp.updateConstraints { make in
                    make.height.equalTo(0)
                }
            }
            
            if let thread = message?.chatThread, self.showThread {
                self.threadView.isHidden = false
                self.threadView.thread = thread
                
            } else {
                self.threadView.isHidden = true
                self.threadView.thread = nil
            }
            self.threadView.snp.updateConstraints { make in
                make.height.equalTo(self.threadView.viewHeight)
            }
        }
    }
    
    func setupContentView(_ view: UIView) {
        
    }
    
    func update(_ message: EMChatMessage?) {
        
    }
    
    func cellHeight(width: CGFloat) -> CGFloat {
        self.layoutIfNeeded()
        var height: CGFloat = 52
        if self.showThread {
            height += self.threadView.bounds.height
        }
        if self.showReaction {
            height += self.reactionView.bounds.height
        }
        return height
    }
    
    @objc private func longPressAction(_ ges: UILongPressGestureRecognizer) {
        if ges.state == .began {
            if let message = message {
                self.didLongPressHandle?(message)
            }
        }
    }
}
