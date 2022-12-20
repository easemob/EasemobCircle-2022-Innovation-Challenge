//
//  MessageCommonView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/1.
//

import UIKit

class MessageCommonView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    var clickHeadHandle: (() -> Void)?
    
    @IBAction func clickHeadAction() {
        self.clickHeadHandle?()
    }
}
