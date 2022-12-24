//
//  UserOnlineManager.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/30.
//

import UIKit
import HyphenateChat

class UserOnlineManager: NSObject {
    
    static let shared = UserOnlineManager()
    
    private var onlineMap: [String: Bool] = [:]
    
    public func addDelete() {
        EMClient.shared().presenceManager?.add(self, delegateQueue: nil)
    }
    
    public func subscribe(members: [String], handle: (() -> Void)?) {
        EMClient.shared().presenceManager?.subscribe(members, expiry: 30 * 24 * 3600) { presences, error in
            DispatchQueue.main.async {
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let presences = presences {
                    self.presenceStatusDidChanged(presences)
                }
                handle?()
            }
        }
    }
    
    public func checkIsOnline(userId: String) -> Bool {
        return self.onlineMap[userId] ?? false
    }
}

extension UserOnlineManager: EMPresenceManagerDelegate {
    func presenceStatusDidChanged(_ presences: [EMPresence]) {
        for presence in presences {
            self.onlineMap[presence.publisher] = presence.userStatus == .online
        }
    }
}
