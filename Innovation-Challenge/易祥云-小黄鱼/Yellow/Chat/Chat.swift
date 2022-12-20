//
//  Chat.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/29.
//

import Foundation
import HyphenateChat

enum Chat {
    case p2p(_ userId: String)
    case circle(_ server: EMCircleServer, channel: EMCircleChannel, thread: EMChatThread?)
}

extension Chat {
    
    var EMChatType: EMChatType {
        if case .p2p(_) = self {
            return .chat
        }
        return .groupChat
    }
    
    var conversationId: String {
        switch self {
            case .p2p(let userId):
                return userId
            case let .circle(_, channel, thread):
                return thread?.threadId ?? channel.channelId
        }
    }
    
    var conversationType: EMConversationType {
        if case .p2p(_) = self {
            return .chat
        }
        return .groupChat
    }
    
    var conversation: EMConversation? {
        EMClient.shared().chatManager?.getConversation(conversationId, type: conversationType, createIfNotExist: true, isThread: isThread, isChannel: isChannel)
    }
    
    var isChannel: Bool {
        guard case .circle(let server, let channel, let thread) = self, thread == nil, server.defaultChannelId == channel.channelId else {
            return false
        }

        return true
    }
    
    var isThread: Bool {
        guard case .circle(_, _, let thread) = self, thread != nil else {
            return false
        }
        
        return true
    }
    
    var isP2p: Bool {
        guard case .p2p(_) = self else {
            return false
        }

        return true
    }
        
    var isCircle: Bool {
        return !isP2p
    }
    
    var server: EMCircleServer? {
        guard case .circle(let server, _, _) = self else {
            return nil
        }
        
        return server
    }
}
