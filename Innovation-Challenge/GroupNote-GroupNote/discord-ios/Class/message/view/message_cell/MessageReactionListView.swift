//
//  MessageReactionListView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/6.
//

import UIKit
import HyphenateChat

class MessageReactionListView: UIView {

    private static var viewPool: Set<MessageReactionItemView> = Set()
    
    private var views: [MessageReactionItemView] = []
    private var message: EMChatMessage?
    
    private  let emojiButton = UIButton(type: .custom)
    
    var didSelectedReaction: ((_ message: EMChatMessage, _ reaction: EMMessageReaction) -> Void)?
    var didClickEmoji: ((_ message: EMChatMessage) -> Void)?
    
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
        self.backgroundColor = UIColor.clear
        self.emojiButton.setImage(UIImage(named: "add_reaction"), for: .normal)
        self.emojiButton.addTarget(self, action: #selector(addEmojiAction), for: .touchUpInside)
        self.addSubview(emojiButton)
    }
    
    public func setMessage(_ message: EMChatMessage) {
        self.message = message
        let reactionCount = message.reactionList?.count ?? 0
        if self.views.count > reactionCount {
            let removeCount = self.views.count - reactionCount
            for _ in 0..<removeCount {
                let view = self.views.removeLast()
                view.removeFromSuperview()
                MessageReactionListView.viewPool.insert(view)
            }
        }
        guard let reactions = message.reactionList else {
            return
        }
        var beginX: CGFloat = 0
        var beginY: CGFloat = 8
        for i in 0..<reactions.count {
            var view: MessageReactionItemView!
            if i < self.views.count {
                view = self.views[i]
            } else {
                view = MessageReactionListView.viewPool.popFirst()
                if view == nil {
                    view = MessageReactionItemView()
                }
                self.views.append(view)
                self.addSubview(view)
            }
            let reaction = reactions[i]
            if let reactionName = emojiImageName(text: reaction.reaction ?? "") {
                view.setReaction(reactionName, count: reaction.count, isAdded: reaction.isAddedBySelf)
            }
            let viewWidth = view.maxWidth
            if viewWidth + beginX > UIScreen.main.bounds.width - 76 {
                beginY += 32
                beginX = 0
            }
            view.frame = CGRect(x: beginX, y: beginY, width: viewWidth, height: 24)
            view.tag = i
            view.clickHandle = { [unowned self] view in
                if let reaction = self.message?.reactionList?[view.tag] {
                    self.didSelectedReaction?(message, reaction)
                }
            }
            beginX += viewWidth + 8
        }
        self.emojiButton.isHidden = reactions.count <= 0
        if beginX + 24 > UIScreen.main.bounds.width - 76 {
            beginY += 32
            beginX = 0
        }
        self.emojiButton.frame = CGRect(x: beginX, y: beginY, width: 24, height: 24)
    }
    
    var maxHeight: CGFloat {
        if let count = self.message?.reactionList?.count, count > 0 {
            return self.emojiButton.frame.maxY + 8
        } else {
            return 0
        }
    }
    
    @objc private func addEmojiAction() {
        if let message = message {
            self.didClickEmoji?(message)
        }
    }
}
