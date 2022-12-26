//
//  ServerRoleManager.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/9/2.
//

import UIKit
import HyphenateChat

class ServerRoleManager: NSObject {

    static let shared = ServerRoleManager()
    
    private var roleMap: [String: EMCircleUserRole] = [:]
    
    func addDelete() {
        EMClient.shared().circleManager?.add(serverDelegate: self, queue: nil)
    }
    
    func queryServerRole(serverId: String, completionHandle: @escaping (_ role: EMCircleUserRole) -> Void) {
        if let role = self.roleMap[serverId] {
            completionHandle(role)
            return
        }
        EMClient.shared().circleManager?.fetchSelfServerRole(serverId, completion: { role, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                self.roleMap[serverId] = role
                completionHandle(role)
            }
        })
    }
    
    func clear() {
        self.roleMap.removeAll()
    }
}

extension ServerRoleManager: EMCircleManagerServerDelegate {
    func onServerRoleAssigned(_ serverId: String, member: String, role: EMCircleUserRole) {
        if member == EMClient.shared().currentUsername {
            self.roleMap[serverId] = role
        }
    }
    
    func onServerDestroyed(_ serverId: String, initiator: String) {
        self.roleMap[serverId] = nil
    }
    
    func onMemberLeftServer(_ serverId: String, member: String) {
        if member == EMClient.shared().currentUsername {
            self.roleMap[serverId] = nil
        }
    }
    
    func onMemberRemoved(fromServer serverId: String, members: [String]) {
        for member in members where member == EMClient.shared().currentUsername {
            self.roleMap[serverId] = nil
            break
        }
    }
}
