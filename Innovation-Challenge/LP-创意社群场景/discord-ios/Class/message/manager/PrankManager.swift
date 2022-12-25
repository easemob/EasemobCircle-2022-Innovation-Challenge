//
//  PrankManager.swift
//  discord-ios
//
//  Created by mac on 2022/12/25.
//

import Foundation

class PrankManager: NSObject {
    static let share = PrankManager()
    
    var curPrankUid: String = ""
}
