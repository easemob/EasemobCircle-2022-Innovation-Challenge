//
//  MessageServerChannelHeader.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/1.
//

import UIKit

class MessageServerChannelHeader: UITableViewHeaderFooterView {

    @IBOutlet private weak var foldButton: UIButton!
    @IBOutlet private weak var createButton: UIButton!
    
    var createHandle: (() -> Void)?
    var foldHandle: (() -> Void)?
    
    var createEnable: Bool = false {
        didSet {
            self.createButton.isHidden = !self.createEnable
        }
    }
    
    var isFold: Bool = false {
        didSet {
            self.foldButton.transform = self.isFold ? CGAffineTransform.identity : CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
    
    @IBAction func createAction() {
        self.createHandle?()
    }
    
    @IBAction func foldAction() {
        UIView.animate(withDuration: 0.3) {
            self.foldButton.transform = self.isFold ? CGAffineTransform(rotationAngle: CGFloat.pi) : CGAffineTransform.identity
        }
        self.foldHandle?()
    }
}
