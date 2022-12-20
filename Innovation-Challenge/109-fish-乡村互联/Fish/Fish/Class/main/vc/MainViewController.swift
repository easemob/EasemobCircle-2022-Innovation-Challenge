//
//  MainViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import UIKit
import HyphenateChat

class MainViewController: UITabBarController {
    
    private var inviteQueue: [ServerJoinAlertViewController.ShowType] = []
    private var currentShowType: ServerJoinAlertViewController.ShowType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barStyle = .black
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.black
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
        UINavigationBar.appearance().backIndicatorImage = UIImage()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()
        let messageVc = self.createMessageViewController()
        let squareVc = self.createSquareViewController()
        let contactsVc = self.createContactsViewController()
        let meVc = self.createMeViewController()
        self.viewControllers = [messageVc, squareVc, contactsVc, meVc]
        self.tabBar.backgroundColor = UIColor.black
        EMClient.shared().circleManager?.add(serverDelegate: self, queue: nil)
        EMClient.shared().circleManager?.add(channelDelegate: self, queue: nil)
        EMClient.shared().addMultiDevices(delegate: self, queue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvJoindServerNotification(_:)), name: EMCircleDidJoinedServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvJoindChannelNotification(_:)), name: EMCircleDidJoinChannel, object: nil)
    }
//RenderingModeAlwaysOriginal
    private func createMessageViewController() -> UIViewController {
        let vc = MessageViewController()
        let navVc = NavigationController(rootViewController: vc)
        let tabbar = UITabBarItem(title: nil, image: UIImage(named: "tab_item_message")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab_item_message_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        navVc.tabBarItem = tabbar
        return navVc
    }
    
    private func createSquareViewController() -> UIViewController {
        let vc = SquareViewController()
        let navVc = NavigationController(rootViewController: vc)
        let tabbar = UITabBarItem(title: nil, image: UIImage(named: "tab_item_square")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab_item_square_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        navVc.tabBarItem = tabbar
        return navVc
    }
    
    private func createContactsViewController() -> UIViewController {
        let vc = ContactsViewController()
        let navVc = NavigationController(rootViewController: vc)
        let tabbar = UITabBarItem(title: nil, image: UIImage(named: "tab_item_contacts")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab_item_contacts_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        navVc.tabBarItem = tabbar
        return navVc
    }
    
    private func createMeViewController() -> UIViewController {
        let vc = UserInfoViewController(showType: .me)
        let navVc = NavigationController(rootViewController: vc)
        let tabbar = UITabBarItem(title: nil, image: UIImage(named: "tab_item_me")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal), selectedImage: UIImage(named: "tab_item_me_selected")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal))
        navVc.tabBarItem = tabbar
        return navVc
    }
    
    @objc private func didRecvJoindServerNotification(_ notification: Notification) {
        if let server = notification.object as? EMCircleServer {
            self.removeServerInvite(serverId: server.serverId)
        }
    }
    
    @objc private func didRecvJoindChannelNotification(_ notification: Notification) {
        if let channel = notification.object as? EMCircleChannel {
            self.removeChannelInvite(channelId: channel.channelId)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension MainViewController: EMCircleManagerServerDelegate, EMCircleManagerChannelDelegate {
    func onReceiveServerInvitation(_ event: EMCircleServerEvent, inviter: String) {
        let showType = ServerJoinAlertViewController.ShowType.inviteServer(serverId: event.serverId, inviter: inviter) { [unowned self] _ in
            self.currentShowType = nil
            self.showNext()
        } refuseHandle: { [unowned self] in
            self.currentShowType = nil
            self.showNext()
        }
        self.inviteQueue.append(showType)
        self.showNext()
    }

    func onReceiveChannelInvitation(_ invite: EMCircleChannelExt, inviter: String) {
        let showType = ServerJoinAlertViewController.ShowType.inviteChannel(inviteInfo: invite, inviter: inviter) { [unowned self] _ in
            self.currentShowType = nil
            self.showNext()
        } refuseHandle: { [unowned self] in
            self.currentShowType = nil
            self.showNext()
        }
        self.inviteQueue.append(showType)
        self.showNext()
    }
    
    private func showNext() {
        if self.currentShowType != nil {
            return
        }
        if self.inviteQueue.count <= 0 {
            self.currentShowType = nil
            return
        }
        let showType = self.inviteQueue.removeFirst()
        self.currentShowType = showType
        let vc = ServerJoinAlertViewController(showType: showType)
        self.present(vc, animated: true)
    }
    
    private func removeServerInvite(serverId: String) {
        for i in (0..<self.inviteQueue.count).reversed() {
            let showType = self.inviteQueue[i]
            switch showType {
            case .inviteServer(serverId: let sId, inviter: _, joinHandle: _, refuseHandle: _):
                if serverId == sId {
                    self.inviteQueue.remove(at: i)
                }
            default:
                break
            }
        }
        switch self.currentShowType {
        case .inviteServer(serverId: let sId, inviter: _, joinHandle: _, refuseHandle: _):
            if serverId == sId {
                self.dismiss(animated: true)
                self.showNext()
            }
        default:
            break
        }
    }
    
    private func removeChannelInvite(channelId: String) {
        for i in (0..<self.inviteQueue.count).reversed() {
            let showType = self.inviteQueue[i]
            switch showType {
            case .inviteChannel(inviteInfo: let channelExt, inviter: _, joinHandle: _, refuseHandle: _):
                if channelId == channelExt.channelId {
                    self.inviteQueue.remove(at: i)
                }
            default:
                break
            }
        }
        switch self.currentShowType {
        case .inviteChannel(inviteInfo: let channelExt, inviter: _, joinHandle: _, refuseHandle: _):
            if channelId == channelExt.channelId {
                self.dismiss(animated: true)
                self.showNext()
            }
        default:
            break
        }
    }
}

extension MainViewController: EMMultiDevicesDelegate {
    func multiDevicesCircleServerEventDidReceive(_ aEvent: EMMultiDevicesEvent, serverId aServerId: String, ext aExt: Any?) {
        switch aEvent {
        case .circleServerInviteBeAccepted, .circleServerInviteBeDeclined, .circleServerJoin:
            self.removeServerInvite(serverId: aServerId)
        default:
            break
        }
    }
    
    func multiDevicesCircleChannelEventDidReceive(_ aEvent: EMMultiDevicesEvent, channelId aChannelId: String, ext aExt: Any?) {
        switch aEvent {
        case .circleChannelInviteBeAccepted, .circleChannelInviteBeDeclined, .circleChannelJoin:
            self.removeChannelInvite(channelId: aChannelId)
        default:
            break
        }
    }
}
