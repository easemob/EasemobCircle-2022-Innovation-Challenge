//
//  NearbyPoint.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/25.
//

import Foundation
import MultipeerConnectivity
import HyphenateChat
import UIKit

private let serviceType = "rb-yellow"

protocol NearbyUserRender: AnyObject {
    func reload()
}

///
class NearbyPoint: NSObject {
    
    static let instance = NearbyPoint()
    
    fileprivate var advertiser: MCNearbyServiceAdvertiser?
    
    fileprivate var browser: MCNearbyServiceBrowser?
    
    private(set) var nearbyUsers: [NearbyUser] = []
    
    weak var render: NearbyUserRender?
    
    private override init() {
        super.init()
    }
    
    var myPeer: MCPeerID {
        MCSessionHolder.shared.myPeer
    }
    
    func start() {
        
        MCSessionHolder.shared.setup()
        
        let ownInfo = UserInfoManager.shared.ownUserInfo
        guard let avatarUrl = ownInfo?.avatarUrl, let nickname = ownInfo?.nickname, let gender = ownInfo?.gender else {
            fatalError()
        }
        
        advertiser = MCNearbyServiceAdvertiser(peer: myPeer, discoveryInfo: ["avatarUrl": avatarUrl, "nickname": nickname, "gender": "\(gender)"], serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        
        browser = MCNearbyServiceBrowser(peer: myPeer, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        
        EMClient.shared().chatManager?.add(self, delegateQueue: nil)
    }
    
}

///
extension NearbyPoint: MCNearbyServiceBrowserDelegate {
        
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        if let index = nearbyUsers.firstIndex(where: { u in
            u.peer == peerID
        }) {
            nearbyUsers[index] = nearbyUsers[index].leave()
            nearbyUsers = nearbyUsers.sorted(by: { n1, n2 in
                n1.distance > n2.distance
            })
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) { }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        
        guard let avatarUrl = info?["avatarUrl"], let nickname = info?["nickname"], let gender = info?["gender"] else {
            fatalError()
        }
        
        var user = NearbyUser(peerID, nickname: nickname, avatar: avatarUrl, gender: gender)
        
        // 将用户信息缓存一下
        let m = EMUserInfo()
        
        m.userId = user.userId
        m.gender = user.gender
        m.nickname = user.nickname
        m.avatarUrl = user.avatar
            
        UserInfoManager.shared[user.userId] = m
        
        if let index = nearbyUsers.firstIndex(where: { u in
            u.userId == user.userId
        }) {
            nearbyUsers[index] = user
            render?.reload()
        } else {
            nearbyUsers.append(user)
            render?.reload()
        }
        
        UserInfoManager.shared.fetchUserInfo(user.userId, forceUpdate: true) { emInfo in
            DispatchQueue.main.async { [unowned self]in
                if let info = emInfo {
                    user = user.update(info)
                    
                    if let index = nearbyUsers.firstIndex(where: { n in
                        n.userId == user.userId
                    }) {
                        nearbyUsers[index] = user
                        render?.reload()
                    }
                }
            }
        }
    }
}

///
extension NearbyPoint: MCNearbyServiceAdvertiserDelegate {
            
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 自动同意 建立链接
        invitationHandler(true, MCSessionHolder.shared.session)
    }
}


extension NearbyPoint: EMChatManagerDelegate {
    
    func messagesDidRead(_ aMessages: [EMChatMessage]) {
        for m in aMessages {
            //
            if let index = nearbyUsers.firstIndex(where: { u in
                u.userId == m.from
            }) {
                let count = EMClient.shared().chatManager?.getConversationWithConvId(m.from)?.unreadMessagesCount ?? 0
                nearbyUsers[index] = nearbyUsers[index].updateUnReadCount(count)
                render?.reload()
            }
        }
    }
}
