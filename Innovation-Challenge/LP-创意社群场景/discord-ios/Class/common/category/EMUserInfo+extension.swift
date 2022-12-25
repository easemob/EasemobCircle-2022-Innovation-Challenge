//
//  EMUserInfo+extension.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/8.
//

import HyphenateChat

extension EMUserInfo {
    var showname: String? {
        if let nickname = self.nickname, nickname.count > 0 {
            return nickname
        }
        return self.userId
    }
}
