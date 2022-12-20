//
//  IEMChatManager+send.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/5.
//

import Foundation
import HyphenateChat

extension IEMChatManager {
    func createSendMessage(body: EMMessageBody, chatType: ChatType) -> EMChatMessage? {
        var type: EMChatType?
        var isChannelMessage = false
        var isChatThreadMessage = false
        switch chatType {
        case .single:
            type = .chat
        case .channel:
            type = .groupChat
            isChannelMessage = true
        case .group:
            type = .groupChat
        case .thread:
            type = .groupChat
            isChatThreadMessage = true
        }
        guard let from = EMClient.shared().currentUsername, let type = type else {
            return nil
        }
        let to = chatType.conversationId
        let message = EMChatMessage(conversationID: to, from: from, to: to, body: body, ext: nil)
        message.isChannelMessage = isChannelMessage
        message.chatType = type
        message.isChatThreadMessage = isChatThreadMessage
        return message
    }
}
