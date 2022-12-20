//
//  Holder.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/12/1.
//

import Foundation
import MultipeerConnectivity
import HyphenateChat

class MCSessionHolder: NSObject {
    
    static let shared = MCSessionHolder()
    
    private override init() { }
        
    private(set) var myPeer: MCPeerID!
    private(set) var session: MCSession!
    
    func setup() {
        guard let info = UserInfoManager.shared.ownUserInfo else {
            fatalError()
        }
        
        myPeer = MCPeerID(displayName: info.senderId)
        session = MCSession(peer: myPeer)
        session.delegate = self
    }
}

extension MCSessionHolder: MCSessionDelegate {
    
    // Remote peer changed state.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) { }

    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let cmd = String(data: data, encoding: .utf8)
        if cmd == "hi" {
            
            let message = EMChatMessage(conversationId: peerID.userId, from: peerID.userId, to: myPeer.userId, body: .custom("hi", customExt: [:]), ext: nil)
            
            let conversation = EMClient.shared().chatManager?.getConversation(peerID.userId, type: .chat, createIfNotExist: true)
            
            conversation?.insert(message, error: nil)
            
            // 将用户信息更新进去
            
        }
    }

    
    // Received a byte stream from remote peer.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) { }

    
    // Start receiving a resource from remote peer.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) { }

    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}

extension MCPeerID {
    
    var userId: String {
        return displayName
    }
}

struct NearbyUser: Equatable {
    
    let peer: MCPeerID
    
    var userId: String {
        return peer.userId
    }
    
    private(set) var nickname: String
    private(set) var avatar: String
    private(set) var gender: Int
    
    private(set) var distance: Double
    
    private(set) var unreadCount: Int32
    
    init(_ peer: MCPeerID, nickname: String, avatar: String, gender: String) {
        self.peer = peer
        self.nickname = nickname
        self.avatar = avatar
        self.gender = Int(gender) ?? 0
        distance = Double.random(in: 0..<10)
        unreadCount = 0
    }
    
   mutating func update(_ info: EMUserInfo) -> NearbyUser {
       if let n = info.nickname, n != nickname {
           nickname = n
       }
       if let a = info.avatarUrl, a != avatar {
           avatar = a
       }
       return self
    }
    
    mutating func leave() -> NearbyUser {
        distance = 100
        return self
    }
    
    mutating func updateUnReadCount(_ count: Int32) -> NearbyUser {
        unreadCount = count
        return self
    }
}
