//
//  MessageCircleInviteCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/2.
//

import UIKit
import HyphenateChat
import SnapKit

class MessageCircleInviteCell: MessageBaseCell {

    private var inviteView: MessageCircleInviteView!
    
    var clickHandle: (() -> Void)?
    
    override func setupContentView(_ view: UIView) {
        let inviteView = Bundle.main.loadNibNamed("MessageCircleInviteView", owner: nil)!.first as! MessageCircleInviteView
        view.addSubview(inviteView)
        inviteView.snp.makeConstraints { make in
            make.left.top.bottom.right.equalTo(0)
            make.height.equalTo(64).priority(.high)
        }
        self.inviteView = inviteView
        let btn = UIButton()
        btn.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(inviteView)
        }
    }
    
    override func update(_ message: EMChatMessage?) {
        guard let body = message?.body as? EMCustomMessageBody else {
            return
        }
        
        if let serverId = body.customExt["server_name"], let server = ServerInfoManager.shared.getServerInfo(serverId: serverId) {
            self.inviteView.iconImageView.setImage(withUrl: server.icon, placeholder: "server_head_placeholder")
            self.inviteView.serverNameLabel.text = server.name
        } else {
            self.inviteView.iconImageView.setImage(withUrl: body.customExt["icon"], placeholder: "server_head_placeholder")
            self.inviteView.serverNameLabel.text = body.customExt["server_name"]
        }
        if body.event == "invite_server" {
            self.inviteView.snp.updateConstraints { make in
                make.height.equalTo(64).priority(.high)
            }
            self.inviteView.channelNameLabel.text = nil
        } else {
            self.inviteView.snp.updateConstraints { make in
                make.height.equalTo(84).priority(.high)
            }
            self.inviteView.channelNameLabel.text = body.customExt["channel_name"]
        }
    }
    
    @objc private func clickAction() {
        self.clickHandle?()
    }
}
