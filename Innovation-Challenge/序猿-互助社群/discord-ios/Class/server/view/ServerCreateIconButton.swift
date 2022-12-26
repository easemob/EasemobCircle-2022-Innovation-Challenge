//
//  ServerCreateIconButton.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/24.
//

import UIKit

class ServerCreateIconButton: UIButton {

    enum ShowType {
        case create
        case update
    }
    
    private let backgroundImageView = UIImageView()
    
    public var showType: ShowType! {
        didSet {
            switch showType {
            case .create:
                self.setTitle("社区封面", for: .normal)
                self.setImage(UIImage(named: "add_white"), for: .normal)
            case .update:
                self.setTitle("更换封面", for: .normal)
                self.setImage(UIImage(named: "server_icon_change"), for: .normal)
            case .none:
                break
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selfInit()
    }
    
    private func selfInit() {
        self.backgroundColor = UIColor(named: ColorName_474747)
        self.layer.masksToBounds = true
        
        self.setTitleColor(UIColor.white, for: .normal)
        self.setTitleColor(UIColor.white, for: .highlighted)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.titleLabel?.textAlignment = .center
        
        self.insertSubview(self.backgroundImageView, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.backgroundImageView.frame = self.bounds
        self.titleLabel?.frame = CGRect(x: 0, y: 68, width: self.bounds.width, height: 16)
        self.imageView?.frame = CGRect(x: 46, y: 36, width: 28, height: 28)
    }
    
    override func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        self.backgroundImageView.image = image
    }
}
