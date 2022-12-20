//
//  MessageGroupNoteCell.swift
//  discord-ios
//
//  Created by zky on 2022/12/18.
//

import UIKit
import HyphenateChat

class MessageGroupNoteCell: MessageBaseCell {
    private let contentTextLabel = UILabel()
    private let joinGroupNoteLabel = UILabel()
    
    var didTapBlock: ((GroupNote) -> Void)?
    
    private var groupNote: GroupNote?
    
    override func setupContentView(_ view: UIView) {
        self.contentTextLabel.numberOfLines = 0
        self.contentTextLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentTextLabel.textColor = UIColor.white
        view.addSubview(self.contentTextLabel)
        self.contentTextLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(0)
            make.top.equalTo(view)
        }
        self.contentTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.contentTextLabel.setContentHuggingPriority(.required, for: .vertical)
        
        joinGroupNoteLabel.text = "参与接龙 >"
        joinGroupNoteLabel.font = UIFont.systemFont(ofSize: 12)
        joinGroupNoteLabel.textColor = UIColor.white
        joinGroupNoteLabel.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(joinGroupNote))
        joinGroupNoteLabel.addGestureRecognizer(tapGesture)
        
        view.addSubview(joinGroupNoteLabel)

        joinGroupNoteLabel.snp.makeConstraints { make in
            make.top.equalTo(contentTextLabel.snp.bottom).offset(10)
            make.width.equalTo(100)
            make.leading.equalTo(contentTextLabel)
            make.bottom.equalTo(view)
        }
        
        joinGroupNoteLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        joinGroupNoteLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    override func update(_ message: EMChatMessage?) {
        if let body = message?.body as? EMCustomMessageBody,
                    body.event == GroupNoteEvent {
            
            if let groupNoteString = body.customExt["body"],
                let groupNoteData = groupNoteString.data(using: .utf8),
                let groupNote = try? JSONDecoder().decode(GroupNote.self, from: groupNoteData) {
                
                self.groupNote = groupNote
                var text = groupNote.noteMessage + "\n"
                if let example = groupNote.example {
                    text += example + "\n"
                }
                
                groupNote.posts.enumerated().forEach { (index, post) in
                    text += "\n\(index + 1). \(post.postMessage)"
                }
                
                contentTextLabel.attributedText = NSAttributedString(emojiText: text, fontSize: self.contentTextLabel.font.pointSize)
            }
        }
    }
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        var height = super.cellHeight(width: width)
        if let attributeString = self.contentTextLabel.attributedText {
            height += attributeString.boundingRect(with: CGSize(width: width, height: 10000), context: nil).height
        }
        return height + 30
    }
    
    @objc private func joinGroupNote() {
        if let groupNote = groupNote {
            didTapBlock?(groupNote)
        }
    }
}
