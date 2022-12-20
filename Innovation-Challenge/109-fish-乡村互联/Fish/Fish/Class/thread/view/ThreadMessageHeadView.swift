//
//  ThreadMessageHeadView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/29.
//

import UIKit
import HyphenateChat

class ThreadMessageHeadView: UIView {

    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var creatorNameLabel: UILabel!
    @IBOutlet private weak var messageView: UIView!
    @IBOutlet private weak var noMessageLabel: UILabel!
    @IBOutlet private weak var hasMessageLabel: UILabel!
    @IBOutlet private weak var messageViewHeightConstraint: NSLayoutConstraint!
    var messageCell: MessageBaseCell?
    
    var didChangeHeight: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        EMClient.shared().threadManager?.add(self, delegateQueue: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        EMClient.shared().threadManager?.add(self, delegateQueue: nil)
    }
    
    var threadId: String? {
        didSet {
            guard let threadId = threadId else {
                return
            }
            EMClient.shared().threadManager?.getChatThread(fromSever: threadId) { [weak self] thread, error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    self.nameLabel.text = thread?.threadName
                    if let userId = thread?.owner {
                        UserInfoManager.share.queryUserInfo(userId: userId, loadCache: true) { userInfo, error in
                            if let error = error {
                                Toast.show(error.errorDescription, duration: 2)
                            } else {
                                self.creatorNameLabel.text = userInfo?.showname
                            }
                        }
                    }
                    if let messageId = thread?.messageId, let message = EMClient.shared().chatManager?.getMessageWithMessageId(messageId) {
                        
                        let cell = ThreadUtils.createMessageCell(message: message)
                        guard let cell = cell else {
                            return
                        }
                        self.messageCell = cell
                        self.messageView.addSubview(cell.contentView)
                        cell.contentView.snp.makeConstraints { make in
                            make.edges.equalTo(0)
                        }
                        self.noMessageLabel.isHidden = true
                        self.hasMessageLabel.isHidden = false
                    } else {
                        self.noMessageLabel.isHidden = false
                        self.hasMessageLabel.isHidden = true
                    }
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var cellHeight: CGFloat = 50
        if let messageCell = self.messageCell {
            cellHeight = messageCell.cellHeight(width: UIScreen.main.bounds.width - 76)
        }
        self.messageViewHeightConstraint.constant = cellHeight
        let height = cellHeight + 136
        self.frame = CGRect(x: self.frame.minX, y: self.frame.minY, width: self.frame.width, height: height)
        self.didChangeHeight?()
    }
    
    deinit {
        EMClient.shared().threadManager?.remove(self)
    }
}

extension ThreadMessageHeadView: EMThreadManagerDelegate {
    func onChatThreadUpdate(_ event: EMChatThreadEvent) {
        if event.type == .update, let threadId = event.chatThread.threadId, self.threadId == threadId, let name = event.chatThread.threadName {
            self.nameLabel.text = name
        }
    }
}
