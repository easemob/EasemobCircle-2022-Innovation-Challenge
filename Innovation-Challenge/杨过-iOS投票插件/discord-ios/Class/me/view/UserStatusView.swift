//
//  UserStatusView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/30.
//

import UIKit

class UserStatusView: UIView {

    enum Status {
        case offline
        case online
    }
    
    private let statusView = UIView()
    
    @IBInspectable
    var borderWidth: CGFloat = 2 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var status: Status = .offline {
        didSet {
            switch self.status {
            case .offline:
                self.statusView.backgroundColor = UIColor(named: ColorName_C4C4C4)
            case .online:
                self.statusView.backgroundColor = UIColor(named: ColorName_14FF72)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selfInit()
    }
    
    private func selfInit() {
        self.statusView.backgroundColor = UIColor(named: ColorName_C4C4C4)
        self.addSubview(self.statusView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.height / 2
        let statusViewWidth = self.bounds.width - 2 * self.borderWidth
        self.statusView.frame = CGRect(x: self.borderWidth, y: self.borderWidth, width: statusViewWidth, height: statusViewWidth)
        self.statusView.layer.cornerRadius = statusViewWidth / 2
    }
}
