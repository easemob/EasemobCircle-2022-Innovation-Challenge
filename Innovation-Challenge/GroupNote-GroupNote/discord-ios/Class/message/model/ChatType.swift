//
//  ChatType.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/26.
//

import Foundation
import HyphenateChat

protocol ThreadId {
    var threadId: String { get }
}

struct ChannelThreadId: ThreadId {
    let serverId: String
    let channelId: String
    let threadId: String
}

enum ChatType {
    case single(userId: String)
    case group(groupId: String)
    case channel(serverId: String, channelId: String)
    case thread(threadId: ThreadId)
}

extension ChatType {
    var conversationId: String {
        switch self {
        case .single(userId: let userId):
            return userId
        case .group(groupId: let groupId):
            return groupId
        case .channel(serverId: _, channelId: let channleId):
            return channleId
        case .thread(threadId: let threadId):
            return threadId.threadId
        }
    }
    
    func createThreadId(threadId: String) -> ThreadId? {
        switch self {
        case .channel(serverId: let serverId, channelId: let channelId):
            return ChannelThreadId(serverId: serverId, channelId: channelId, threadId: threadId)
        default:
            return nil
        }
    }
}
