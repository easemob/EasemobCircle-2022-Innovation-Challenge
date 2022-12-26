//
//  MessageServerThreadListFooter.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/2.
//

import UIKit

class MessageServerThreadListFooter: UITableViewHeaderFooterView {

    var clickHandle: (() -> Void)?
    
    @IBAction func clickAction() {
        self.clickHandle?()
    }
}
