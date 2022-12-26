//
//  ServerInfoManager.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/19.
//

import UIKit
import HyphenateChat

class ServerInfoManager: NSObject {

    private override init() {
        super.init()
    }
    
    static public let shared = ServerInfoManager()
    
    var serverMap: [String: EMCircleServer] = [:]
    
    func saveServerInfo(servers: [EMCircleServer]) {
        for server in servers {
            self.serverMap[server.serverId] = server
        }
    }
    
    func getServerInfo(serverId: String, refresh: Bool, complate: @escaping (_ server: EMCircleServer?, _ error: EMError?) -> Void) {
        if !refresh, let server = self.serverMap[serverId] {
            complate(server, nil)
            return
        }
        EMClient.shared().circleManager?.fetchServerDetail(serverId) { server, error in
            if let server = server {
                self.serverMap[server.serverId] = server
            }
            complate(server, error)
        }
    }
    
    func getServerInfo(serverId: String) -> EMCircleServer? {
        return self.serverMap[serverId]
    }
    
    func remove(serverId: String) {
        self.serverMap.removeValue(forKey: serverId)
    }
}
