//
//  ServerEditItemButtin.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/29.
//

import UIKit

class ServerEditItemButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.titleLabel?.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabel?.textAlignment = .center
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRect(x: (self.bounds.width - 36) / 2, y: 0, width: 36, height: 36)
        self.titleLabel?.frame = CGRect(x: 0, y: self.bounds.height - 16, width: self.bounds.width, height: 16)
    }
}
