//
//  MessageCommonView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/1.
//

import UIKit
import YYImage

class MessageCommonView: UIView {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    let prankView: YYAnimatedImageView = {
        let view = YYAnimatedImageView()
        view.backgroundColor = .clear
//        view.image = YYImage.init(named: "prank.webp")
        return view
    }()
    
    var clickHeadHandle: (() -> Void)?
    
    @IBAction func clickHeadAction() {
        self.clickHeadHandle?()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selfInit()
    }
    
    private func selfInit() {
        self.iconImageView.addSubview(prankView)
        prankView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        
    }
    
    func onPrank() {
        prankView.image = YYImage.init(named: "prank.webp")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.prankView.image = YYImage()
        }
    }
    
    func onStopPrank() {
        self.prankView.image = YYImage()
    }
}
