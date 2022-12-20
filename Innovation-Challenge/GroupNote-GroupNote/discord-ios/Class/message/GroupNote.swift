//
//  GroupNote.swift
//  discord-ios
//
//  Created by zky on 2022/12/17.
//

import Foundation
import HyphenateChat

let GroupNoteEvent = "GroupNote"

struct GroupNote: Codable {
    var noteMessage: String
    var posts: [GroupNotePost]
    let initiator: String
    var example: String?
    
    enum Status: Codable {
        case create
        case update
    }
    
    struct GroupNotePost: Codable {
        let userId: String
        var postMessage: String
    }
    
    static func createdGroupNote() -> GroupNote {
        var posts = [GroupNotePost]()
        if let selfPost = selfPost() {
            posts.append(selfPost)
        }
        
        return GroupNote(noteMessage: "#接龙\n",
                  posts: posts,
                  initiator: EMClient.shared().currentUsername ?? "",
                  example: "")
    }
    
    static func selfPost() -> GroupNotePost? {
        guard let currentUserId = EMClient.shared().currentUsername else {
            return nil
        }
        
        let postMessage = UserInfoManager.share.userInfo(userId: currentUserId)?.showname ?? currentUserId
        
        return GroupNotePost(userId: currentUserId, postMessage: postMessage)
    }
}
