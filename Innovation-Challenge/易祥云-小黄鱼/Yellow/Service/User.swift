//
//  User.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/23.
//

import Foundation
import LeanCloud
import HyphenateChat

private let officialServerId = "1FIzEFoNJ6HYdHmh3x37D5PYDsk"
private let officialChannelId = "199035649589249"
private let officialSupport = "yellow_admin"

enum UserServiceError: Error {
    case invalidUsername
    case api(raw: EMError?)
    case backend(_ message: String)
}



// 注册一个新用户
func register() async throws {
    
    // 先看看
    let user = LCUser()
    
    let r = try await withUnsafeThrowingContinuation { c in
        user.logIn(authData: ["id": UUID().uuidString], platform: .custom("anonymous")) { r in
            c.resume(returning: r)
        }
    }
    
    if case let .failure(err) = r {
        throw err
    }
    
    guard let u = user.username?.value, let p = user.objectId?.value else {
        throw UserServiceError.invalidUsername
    }
    
    // 注册一下环信账号
    let res = await EMClient.shared().register(withUsername: u, password: p)
    
    if res.1 != nil {
        throw res.1!
    }
    
    // 登录环信账号
    let loginRes = await EMClient.shared().login(withUsername: u, password: p)
    if loginRes.1 != nil {
        throw loginRes.1!
    }
    
}

// 登录到环信
func loginIfEMNeeded() async throws {
        
    guard let user = LCApplication.default.currentUser else {
        fatalError()
    }
    
    if (!EMClient.shared().isLoggedIn) {
        // 登录环信
        guard let u = user.username?.value, let p = user.objectId?.value else {
            throw NSError(domain: "User", code: 1)
        }
        
        let r = await EMClient.shared().login(withUsername: u, password: p)
        if r.1 != nil {
            throw r.1!
        }
    }
}

// 确认是否有用户信息
func needConfirmUserInfo() -> Bool {
    
    guard let info = UserInfoManager.shared.ownUserInfo else {
        return true
    }
    
    return info.nickname == nil || info.nickname == "" || info.avatarUrl == nil || info.avatarUrl == "" || info.gender == 0
}

// 加入官方社群
func joinOfficialServerIfNeeded() async {
    
    let checkRes = await EMClient.shared().circleManager?.checkSelfIs(inServer: officialServerId)
    let isSelfIn = checkRes?.0 ?? false
    
    if isSelfIn {
        return
    }
    
    // 加入到官方社区
    let joinRes = await EMClient.shared().circleManager?.joinServer(officialServerId)
    
    if let server = joinRes?.0, server.serverId.count > 0 {
        debugPrint("join official server succeed. \(server.name) \(server.defaultChannelId)")
    }
}

class UserInfoManager {
    
    static let shared = UserInfoManager()
    
    private init() {
        ownUserInfo = EMUserInfo.loadFromLocal()
    }
    
    fileprivate var users = [String: EMUserInfo]()
    
    private(set) var ownUserInfo: EMUserInfo?
    
    subscript(userId: String) -> EMUserInfo? {
        get {
            users[userId]
        }
        set {
            users[userId] = newValue
        }
    }
    
    func updateOwn(_ userInfo: EMUserInfo, result: @escaping (Error?) -> Void) {
        let manager = EMClient.shared().userInfoManager
        
        manager?.updateOwn(userInfo) { newInfo, err in
            DispatchQueue.main.async { [unowned self] in
                if let u = newInfo {
                    self.ownUserInfo = u
                }
                self.ownUserInfo?.saveToLocal()
                NotificationCenter.default.post(name: .ownUserInfoUpdated, object: nil)
                result(err)
            }
        }
    }
        
    func fetchUserInfo(_ userId: String) async throws -> EMUserInfo {
        
        let r = await EMClient.shared().userInfoManager?.fetchUserInfo(byId: [userId])
        
        guard let info = r?.0?.values.first as? EMUserInfo else {
            throw UserServiceError.api(raw: r?.1)
        }
        
        DispatchQueue.main.async { [unowned self] in
            if let id = info.userId {
                self.users[id] = info
            }
        }
        
        return info
    }
    
    func prefetchChannelMembers(serverId: String, channel: String) async {
        var cursor: String?
        repeat {
            let r = await EMClient.shared().circleManager?.fetchServerMembers(serverId, limit: 100, cursor: cursor)
            cursor = r?.0?.cursor
            if let users = r?.0?.list {
                prefetchUserInfos(users.compactMap { $0.userId })
            }
        } while (cursor != nil && cursor != "")
    }
    
    func prefetchUserInfos(_ userIds: [String]) {
        EMClient.shared().userInfoManager?.fetchUserInfo(byId: userIds) { v, _ in
            DispatchQueue.main.async { [unowned self] in
                if let userInfos = v as? [String: EMUserInfo] {
                    users.merge(userInfos) { l, r in
                        r
                    }
                }
            }
        }
    }
    
    func fetchUserInfo(_ userId: String, forceUpdate: Bool = false, result: @escaping (EMUserInfo?) -> ()) {
        
        let info = users[userId]
        
        if info == nil || forceUpdate {
            EMClient.shared().userInfoManager?.fetchUserInfo(byId: [userId]) { v, _ in
                DispatchQueue.main.async { [weak self] in
                    let userInfo = v?.values.first as? EMUserInfo
                    if userInfo != nil {
                        self?.users[userId] = userInfo
                    }
                    result(userInfo)
                }
            }
        } else {
            result(info)
        }
    }
}
