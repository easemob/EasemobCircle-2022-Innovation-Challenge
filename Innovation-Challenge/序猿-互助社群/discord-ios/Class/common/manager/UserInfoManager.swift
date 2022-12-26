//
//  UserInfoManager.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/27.
//

import UIKit
import HyphenateChat

class UserInfoManager {

    static let share = UserInfoManager()
    
    private var userInfoMap: [String: EMUserInfo] = [:]
    
    func queryUserInfo(userIds: [String], handle: (() -> Void)?) {
        var requestList: [String] = []
        for userId in userIds where self.userInfoMap[userId] == nil {
            requestList.append(userId)
        }
        EMClient.shared().userInfoManager?.fetchUserInfo(byId: requestList) { infos, error in
            DispatchQueue.main.async {
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let infos = infos as? [String: EMUserInfo] {
                    for item in infos {
                        self.userInfoMap[item.key] = item.value
                    }
                }
                handle?()
            }
        }
    }
    
    func queryUserInfo(userId: String, loadCache: Bool, handle: @escaping (_ userInfo: EMUserInfo?, _ error: EMError?) -> Void) {
        if loadCache, let userInfo = self.userInfoMap[userId] {
            handle(userInfo, nil)
            return
        }
        EMClient.shared().userInfoManager?.fetchUserInfo(byId: [userId]) { infos, error in
            DispatchQueue.main.async {
                if let error = error {
                    handle(nil, error)
                } else if let infos = infos as? [String: EMUserInfo] {
                    for item in infos {
                        self.userInfoMap[item.key] = item.value
                    }
                    handle(self.userInfoMap[userId], nil)
                }
            }
        }
    }
    
    func storeUserInfo(userInfos: [EMUserInfo]) {
        for info in userInfos where info.userId?.count ?? 0 > 0 {
            self.userInfoMap[info.userId!] = info
        }
    }
    
    func userInfo(userId: String) -> EMUserInfo? {
        return self.userInfoMap[userId]
    }
}
