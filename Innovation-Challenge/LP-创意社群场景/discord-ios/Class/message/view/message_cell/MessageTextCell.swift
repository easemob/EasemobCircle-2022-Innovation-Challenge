//
//  MessageTextCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/1.
//

import UIKit
import HyphenateChat
import SnapKit

class MessageTextCell: MessageBaseCell {
    
    private let contentTextLabel = UILabel()
    
    override func setupContentView(_ view: UIView) {
        self.contentTextLabel.numberOfLines = 0
        self.contentTextLabel.font = UIFont.systemFont(ofSize: 14)
        self.contentTextLabel.textColor = UIColor.white
        view.addSubview(self.contentTextLabel)
        self.contentTextLabel.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        self.contentTextLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        self.contentTextLabel.setContentHuggingPriority(.required, for: .vertical)
    }
    
    override func update(_ message: EMChatMessage?) {
        if let body = message?.body as? EMTextMessageBody {
            self.contentTextLabel.textColor = .white
            self.contentTextLabel.attributedText = NSAttributedString(emojiText: body.text, fontSize: self.contentTextLabel.font.pointSize)
        } else if let body = message?.body as? EMCustomMessageBody {
            if body.event == "join_server" {
                if message?.from == EMClient.shared().currentUsername {
                    let serverName = body.customExt["server_name"] ?? ""
                    self.contentTextLabel.text = "我已加入社区 \(serverName)"
                } else {
                    self.contentTextLabel.text = "加入了社区，和ta打招呼吧"
                }
            } else if body.event == "join_channel" {
                if message?.from == EMClient.shared().currentUsername {
                    let serverName = body.customExt["server_name"] ?? ""
                    let channelName = body.customExt["channel_name"] ?? ""
                    self.contentTextLabel.text = "我已加入频道 \(serverName) - #\(channelName)"
                }
                else {
                    self.contentTextLabel.text = "加入了频道，和ta打招呼吧"
                }
            } else if body.event == "PRANK" {
                let ID = body.customExt["ID"] ?? ""
                let NAME = body.customExt["NAME"] ?? ""
                self.contentTextLabel.textColor = .systemYellow
                self.contentTextLabel.text = "向" + NAME + "投掷了整蛊💣~"
            }
        }
    }
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        var height = super.cellHeight(width: width)
        if let attributeString = self.contentTextLabel.attributedText {
            height += attributeString.boundingRect(with: CGSize(width: width, height: 10000), context: nil).height
//            if height < 20 {
//                height = 30
//            }
        }
        return height
    }
}
