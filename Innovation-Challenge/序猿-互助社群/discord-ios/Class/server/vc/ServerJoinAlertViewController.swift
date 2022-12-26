//
//  ServerJoinAlertViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/30.
//

import UIKit
import HyphenateChat
import Kingfisher
import CoreMedia
import PKHUD

class ServerJoinAlertViewController: UIViewController {

    enum ShowType {
        case joinServer(server: EMCircleServer, joinHandle: ((_ server: EMCircleServer) -> Void))
        case joinChannel(serverId: String, channelId: String, joinHandle: ((_ channel: EMCircleChannel) -> Void))
        case inviteServer(serverId: String, inviter: String, joinHandle: ((_ server: EMCircleServer) -> Void), refuseHandle: (() -> Void)? = nil)
        case inviteChannel(inviteInfo: EMCircleChannelExt, inviter: String, joinHandle: ((_ channel: EMCircleChannel) -> Void), refuseHandle: (() -> Void)? = nil)
    }
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var channelNameLabel: UILabel!
    @IBOutlet private weak var joinButton: UIButton!
    
    let showType: ShowType
        
    init(showType: ShowType) {
        self.showType = showType
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch self.showType {
        case .joinServer(server: let server, _):
            self.updateServerInfo(server: server)
            self.joinButton.setTitle("加入社区", for: .normal)
        case .inviteServer(serverId: let serverId, _, _, _):
            ServerInfoManager.shared.getServerInfo(serverId: serverId, refresh: false) { server, error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let server = server {
                    self.updateServerInfo(server: server)
                }
            }
            self.joinButton.setTitle("加入社区", for: .normal)
        case .joinChannel(serverId: let serverId, channelId: let channelId, _):
            ServerInfoManager.shared.getServerInfo(serverId: serverId, refresh: false) { server, error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let server = server {
                    self.updateServerInfo(server: server)
                }
            }
            EMClient.shared().circleManager?.fetchChannelDetail(serverId, channelId: channelId) { channel, error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let channel = channel {
                    self.channelNameLabel.text = channel.name
                    self.descLabel.text = channel.desc
                }
            }
            self.joinButton.setTitle("加入频道", for: .normal)
        case .inviteChannel(inviteInfo: let info, _, _, _):
            self.iconImageView.setImage(withUrl: info.serverIcon, placeholder: "server_head_placeholder")
            self.nameLabel.text = info.serverName
            self.channelNameLabel.text = info.channelName
            self.descLabel.text = info.channelDesc
            self.joinButton.setTitle("加入频道", for: .normal)
        }
    }
    
    private func updateServerInfo(server: EMCircleServer) {
        self.iconImageView.setImage(withUrl: server.icon, placeholder: "server_head_placeholder")
        self.nameLabel.text = server.name
        switch self.showType {
        case .inviteServer, .joinServer:
            self.descLabel.text = server.desc
        default:
            break
        }
    }

    @IBAction func tapAction() {
        self.dismiss(animated: true)
    }
    
    @IBAction func thinkAction() {
        switch self.showType {
        case .inviteServer(serverId: let serverId, inviter: let inviter, _, let refuseHandle):
            EMClient.shared().circleManager?.declineServerInvitation(serverId, inviter: inviter) { error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                }
            }
            refuseHandle?()
        case .inviteChannel(inviteInfo: let inviteInfo, inviter: let inviter, _, let refuseHandle):
            EMClient.shared().circleManager?.declineChannelInvitation(inviteInfo.serverId, channelId: inviteInfo.channelId, inviter: inviter) { error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                }
            }
            refuseHandle?()
        default:
            break
        }
        self.dismiss(animated: true)
    }
    
    @IBAction func joinAction() {
        HUD.show(.progress, onView: self.view)
        switch self.showType {
        case .joinServer(server: let server, joinHandle: let handle):
            EMClient.shared().circleManager?.joinServer(server.serverId) { server, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let server = server {
                    self.didJoinServer(serverId: server.serverId, server: server)
                    handle(server)
                }
                self.dismiss(animated: true)
            }
        case .joinChannel:
            self.joinChannel(showType: self.showType)
        case .inviteServer(serverId: let serverId, inviter: let inviter, joinHandle: let handle, _):
            EMClient.shared().circleManager?.acceptServerInvitation(serverId, inviter: inviter) { server, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let server = server {
                    self.didJoinServer(serverId: serverId, server: server)
                    handle(server)
                }
                self.dismiss(animated: true)
            }
        case .inviteChannel:
            self.acceptChannelInvitation(showType: self.showType)
        }
    }
    
    private func joinChannel(showType: ShowType) {
        switch showType {
        case .joinChannel(serverId: let serverId, channelId: let channelId, joinHandle: let handle):
            EMClient.shared().circleManager?.joinChannel(serverId, channelId: channelId) { channel, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let channel = channel {
                    Toast.show("加入成功", duration: 2)
                    HUD.show(.progress, onView: self.view)
                    ServerInfoManager.shared.getServerInfo(serverId: serverId, refresh: false) { server, _ in
                        EMClient.shared().circleManager?.fetchChannelDetail(serverId, channelId: channelId) { channel, _ in
                            HUD.hide()
                            self.sendJoinChannelMessage(serverId: serverId, channelId: channelId, serverName: server?.name ?? "", channelName: channel?.name ?? "")
                        }
                    }
                    handle(channel)
                }
                self.dismiss(animated: true)
            }
        default:
            break
        }
    }
    
    private func acceptChannelInvitation(showType: ShowType) {
        switch showType {
        case .inviteChannel(inviteInfo: let inviteInfo, inviter: let inviter, joinHandle: let handle, _):
            EMClient.shared().circleManager?.acceptChannelInvitation(inviteInfo.serverId, channelId: inviteInfo.channelId, inviter: inviter) { channel, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let channel = channel {
                    Toast.show("加入成功", duration: 2)
                    NotificationCenter.default.post(name: EMCircleDidJoinChannel, object: channel)
                    self.sendJoinChannelMessage(serverId: inviteInfo.serverId, channelId: inviteInfo.channelId, serverName: inviteInfo.serverName, channelName: inviteInfo.channelName)
                    handle(channel)
                }
                self.dismiss(animated: true)
            }
        default:
            break
        }
    }
    
    private func didJoinServer(serverId: String, server: EMCircleServer) {
        Toast.show("加入成功", duration: 2)
        NotificationCenter.default.post(name: EMCircleDidJoinedServer, object: server)
        ServerInfoManager.shared.getServerInfo(serverId: serverId, refresh: false) { server, _ in
            if let channelId = server?.defaultChannelId {
                let body = EMCustomMessageBody(event: "join_server", customExt: [
                    "server_name": server?.name ?? ""
                ])
                if let message = EMClient.shared().chatManager?.createSendMessage(body: body, chatType: .channel(serverId: serverId, channelId: channelId)) {
                    EMClient.shared().chatManager?.send(message, progress: nil, completion: nil)
                }
            }
        }
    }
    
    private func sendJoinChannelMessage(serverId: String, channelId: String, serverName: String, channelName: String) {
        let body = EMCustomMessageBody(event: "join_channel", customExt: [
            "server_name": serverName,
            "channel_name": channelName
        ])
        if let message = EMClient.shared().chatManager?.createSendMessage(body: body, chatType: .channel(serverId: serverId, channelId: channelId)) {
            EMClient.shared().chatManager?.send(message, progress: nil, completion: nil)
        }
    }
}
