//
//  Model.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/29.
//

import Foundation
import MessageKit
import HyphenateChat

extension EMCircleServer {
    
    var defaultChannel: EMCircleChannel? {
        return channels?.first
    }
}

extension EMChatMessage {
    
    func isBelong(to chatType: Chat) -> Bool {
        return conversationId == chatType.conversationId
    }
    
}

extension EMChatMessage: SenderType {
    
    public var senderId: String {
        from
    }
    
    public var displayName: String {
        UserInfoManager.shared[senderId]?.nickname ?? ""
    }
    
}

extension EMImageMessageBody: MediaItem {
    
    public var url: URL? {
        URL(string: thumbnailRemotePath)
    }
    
    public var image: UIImage? {
        if let tp = thumbnailLocalPath, let image = UIImage(contentsOfFile: tp)  {
            return image
        }
                
        if let lp = localPath {
            return UIImage(contentsOfFile: lp)
        }
        
        return nil
    }
    
    public var placeholderImage: UIImage {
        UIImage(named: "image_message_placeholder")!
    }
}

extension EMChatMessage: MessageType {
    
    public var sender: MessageKit.SenderType {
        return self
    }
    
    public var sentDate: Date {
        return Date(timeIntervalSince1970: Double(timestamp) / 1000)
    }
    
    public var kind: MessageKit.MessageKind {
        switch body {
            case let textBody as EMTextMessageBody:
                return .text(textBody.text)
            case let imageBody as EMImageMessageBody:
                return .photo(imageBody)
            case is EMCustomMessageBody:
                return .text("👏👏你好呀")
            default:
                return .text("[请下载最新版本]")
        }
    }
    
}

extension EMUserInfo: SenderType {
    
    public var senderId: String {
        userId!
    }
    
    public var displayName: String {
        UserInfoManager.shared[senderId]?.nickname ?? "_loading"
    }
}
