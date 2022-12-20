//
//  CloudDatabase.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/23.
//

import Foundation
import LeanCloud

class CloudDatabase {
    
    static func setup() {
        do {
            try LCApplication.default.set(
                id: "QXM8aR1StigS3UrR4gMwvIF9-gzGzoHsz",
                key: "bJdrXeJUuO1cAx2yU80xYXY7",
                serverURL: "https://rent-api.rainbowbridge.top")
            LCApplication.logLevel = .all
        } catch {
            fatalError()
        }
    }
}
