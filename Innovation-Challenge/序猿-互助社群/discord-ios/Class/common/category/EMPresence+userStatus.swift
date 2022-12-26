//
//  EMPresence+userStatus.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/30.
//

import Foundation
import HyphenateChat

extension EMPresence {
    var userStatus: UserStatusView.Status {
        if let statusDetails = self.statusDetails {
            for status in statusDetails where status.status == 1 {
                return .online
            }
        }
        return .offline
    }
}
