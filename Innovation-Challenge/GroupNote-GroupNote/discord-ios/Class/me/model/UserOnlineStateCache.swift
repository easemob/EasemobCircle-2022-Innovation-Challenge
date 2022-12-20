//
//  UserOnlineStateCache.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/30.
//

import UIKit
import HyphenateChat

class UserOnlineStateCache: NSObject {

    private var userOnlineStatusMap: [String: UserStatusView.Status] = [:]
    
    func refresh(members: [String], completion: @escaping () -> Void) {
        if members.count <= 0 {
            return
        }
        EMClient.shared().presenceManager?.fetchPresenceStatus(members) { presences, error in
            DispatchQueue.main.async {
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let presences = presences {
                    for i in presences {
                        self.userOnlineStatusMap[i.publisher] = i.userStatus
                    }
                    completion()
                }
            }
        }
    }
    
    func getUserStatus(_ userId: String) -> UserStatusView.Status? {
        return userOnlineStatusMap[userId]
    }
}
