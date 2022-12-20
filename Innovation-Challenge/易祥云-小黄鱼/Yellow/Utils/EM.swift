//
//  EM.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/25.
//

import Foundation
import HyphenateChat
import Alamofire
import LeanCloud

struct EM {
    
    static func fetchAll<T>(_ fn: (_ cursor: String?) async -> (EMCursorResult<T>?, EMError?)?) async -> [T] {
        var cursor: String?

        var list = [T]()

        repeat {
            let r = await fn(cursor)
            
            if let l = r?.0?.list {
                list.append(contentsOf: l)
            }

            cursor = r?.0?.cursor

        } while(cursor != nil && cursor != "")
        
        
        return list
    }
}

extension EMError: Error { }

private struct AssociatedKeys {
    
    static var kUserIsInChannel = "kUserIsInChannel"
    
    static var kMembers = "kMembers"
    
    static var kChannels = "kChannels"
    
}

extension EMCircleServer {
    
    var channels: [EMCircleChannel]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kChannels) as? [EMCircleChannel]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kChannels, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func loadChannels() async {
        
        let channels = await EM.fetchAll { cursor in
            await EMClient.shared().circleManager?.fetchPublicChannels(inServer: serverId, limit: 20, cursor: cursor)
        }
        
        for c in channels {
            
            await c.checkIsIn()
            await c.loadMembers()
        }
        
        self.channels = channels
    }
}

extension EMCircleChannel {

    // 确认已经单独请求， 组装过了
    var isIn: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kUserIsInChannel) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kUserIsInChannel, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func checkIsIn() async {
        let r = await EMClient.shared().circleManager?.checkSelfIsInChannel(serverId: serverId, channelId: channelId)
        
        isIn = r?.0 ?? false
    }
    
    //  确认已经单独请求组装过了
    var members: [EMCircleUser]? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kMembers) as? [EMCircleUser]
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kMembers, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func loadMembers() async {
        members = await EM.fetchAll({ cursor in
            await EMClient.shared().circleManager?.fetchChannelMembers(serverId, channelId: channelId, limit: 20, cursor: cursor)
        })
    }
}

struct ChannelExt: Decodable {
    
    let color: UIColor
//    let location: LCGeoPoint
    
    enum CodingKeys: CodingKey {
        case color
        case location
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let hexColor = try container.decode(String.self, forKey: .color)
        color = hexStringToUIColor(hex: hexColor)
//        let locationStr = try container.decode(String.self, forKey: .location)
//        let ll = locationStr.split(separator: ",")
//        guard ll.count == 2 else {
//            throw NSError(domain: "ChannelExt decoder failed", code: 0)
//        }
//        guard let lat = Double(ll[1]), let lon = Double(ll[0]) else {
//            throw NSError(domain: "ChannelExt decoder failed", code: 1)
//        }
//
//        location = LCGeoPoint(latitude: lat, longitude: lon)
    }
}

extension EMCircleChannel {
    
    var custom: ChannelExt? {
        if let data = ext?.data(using: .utf8) {
            return try? JSONDecoder().decode(ChannelExt.self, from: data)
        }
        return nil
    }
}

extension EMUserInfo {
    
    // 1 男 2 女 3 其他
    var genderImage: UIImage? {
        switch gender {
            case 1:
                return UIImage(named: "male")
            case 2:
                return UIImage(named: "female")
            default:
                return UIImage(named: "xmale")
        }
    }
}

// 临时使用一下

extension EMUserInfo {
    
    private var toJson: String {
        return """
{
    "userId": "\(userId!)",
    "nickname": "\(nickname!)",
    "avatarUrl": "\(avatarUrl!)",
    "gender": \(gender)
}
"""
    }
    
    private static func from(json: String) -> EMUserInfo? {
        
        guard let jsonData = json.data(using: .utf8)  else {
            return nil
        }
        guard let map = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else  {
            return nil
        }
        
        let userInfo = EMUserInfo()
        userInfo.userId = map["userId"] as? String
        userInfo.nickname = map["nickname"] as? String
        userInfo.avatarUrl = map["avatarUrl"] as? String
        
        userInfo.gender = map["gender"] as? Int ?? 0
            
        return userInfo
    }
    
    func saveToLocal() {
        UserDefaults.standard.set(toJson, forKey: "k_em_user_json")
        UserDefaults.standard.synchronize()
    }
    
    static func loadFromLocal() -> EMUserInfo? {
        guard let json = UserDefaults.standard.string(forKey: "k_em_user_json"), !json.isEmpty else {
            return nil
        }
        return EMUserInfo.from(json: json)
    }
}
