//
//  ThreadUtils.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/29.
//

import UIKit
import HyphenateChat

class ThreadUtils: NSObject {
    class func createMessageCell(message: EMChatMessage?) -> MessageBaseCell? {
        var cell: MessageBaseCell?
        switch message?.body.type {
        case .text:
            cell = MessageTextCell(style: .default, reuseIdentifier: nil)
        case .image:
            cell = MessageImageCell(style: .default, reuseIdentifier: nil)
        case .file:
            cell = MessageFileCell(style: .default, reuseIdentifier: nil)
        default:
            break
        }
        cell?.showReaction = false
        cell?.showThread = false
        cell?.message = message
        return cell
    }
}
