//
//  EMChatMessage+ChatType.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/9/5.
//

import HyphenateChat

extension EMChatMessage {
    func isBelongTo(chatType: ChatType) -> Bool {
        switch chatType {
        case .single(userId: let userId):
            if self.chatType == .chat && self.from == userId {
                return true
            }
        case .group(groupId: let groupId):
            if self.chatType == .groupChat && self.to == groupId {
                return true
            }
        case .channel(serverId: _, channelId: let channelId):
            if self.chatType == .groupChat && self.to == channelId {
                return true
            }
        case .thread(threadId: let threadId):
            if self.chatType == .groupChat && self.to == threadId.threadId {
                return true
            }
        }
        return false
    }
}
