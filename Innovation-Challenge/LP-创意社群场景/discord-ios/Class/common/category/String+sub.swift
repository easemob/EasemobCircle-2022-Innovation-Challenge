//
//  String+sub.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import Foundation

extension String {
    
    public func subsring(to index: Int) -> String? {
        let end = self.index(startIndex, offsetBy: index)
        if end > endIndex {
            return nil
        }
        return String(self[..<end])
    }

    public func subsring(from index: Int) -> String? {
        let start = self.index(startIndex, offsetBy: index)
        if start < startIndex {
            return nil
        }
        return String(self[start...])
    }
    
}
