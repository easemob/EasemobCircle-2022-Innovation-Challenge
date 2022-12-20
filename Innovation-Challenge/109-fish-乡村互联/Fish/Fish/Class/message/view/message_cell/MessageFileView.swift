//
//  MessageFileView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/28.
//

import UIKit

class MessageFileView: UIView {
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var sizeLabel: UILabel!
    
    var fileName: String? {
        didSet {
            self.nameLabel.text = fileName
        }
    }
    
    var fileSize: Int64? {
        didSet {
            guard let fileSize = fileSize else {
                self.sizeLabel.text = ""
                return
            }
            if fileSize < 1024 {
                self.sizeLabel.text = "\(fileSize)B"
            } else if fileSize < 1024 * 1024 {
                self.sizeLabel.text = "\(fileSize / 1024)K"
            } else if fileSize < 1024 * 1024 * 1024 {
                self.sizeLabel.text = "\(fileSize / 1024 / 1024)M"
            } else {
                self.sizeLabel.text = "\(fileSize / 1024 / 1024 / 1024)G"
            }
        }
    }
}
