//
//  EMChatMessage+showText.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/2.
//

import Foundation
import HyphenateChat

extension EMChatMessage {
    func showText() -> String {
        switch self.body.type {
        case .text:
            return (self.body as! EMTextMessageBody).text
        case .image:
            return "图片"
        case .voice:
            return "录音"
        case .video:
            return "视频"
        case .file:
            return "文件"
        default:
            return "未知消息类型"
        }
    }
    
    func threadShowText() -> String? {
        switch self.body.type {
        case .text:
            return (self.body as? EMTextMessageBody)?.text ?? nil
        case .image:
            return "/图片消息/"
        case .video:
            return "/视频消息/"
        case .file:
            return "/文件/"
        default:
            return "/未知消息类型/"
        }
    }
}
