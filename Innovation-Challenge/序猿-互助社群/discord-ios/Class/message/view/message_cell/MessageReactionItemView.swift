//
//  MessageReactionItemView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/6.
//

import UIKit
import SnapKit

class MessageReactionItemView: UIView {

    private static let fontSize: CGFloat = 14
    private static let imageW: CGFloat = 20
    
    private let imageView = UIImageView()
    private let label = UILabel()
    private let button = UIButton()
    
    var clickHandle: ((_ view: MessageReactionItemView) -> Void)?
    
    public var maxWidth: CGFloat {
        guard let text = self.label.text, let font = self.label.font else {
            return 46
        }
        let attrStr = NSAttributedString(string: text, attributes: [
            .font: font
        ])
        let tagW = attrStr.boundingRect(with: CGSize(width: 1000, height: 1000), options: .usesFontLeading, context: nil).width
        return MessageReactionItemView.imageW + tagW + 6 + 3 + 8
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        self.selfInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.button.frame = self.bounds
        self.imageView.frame = CGRect(x: 6, y: (self.bounds.height - MessageReactionItemView.imageW) / 2, width: MessageReactionItemView.imageW, height: MessageReactionItemView.imageW)
    }
    
    private func selfInit() {
        self.backgroundColor = UIColor(named: ColorName_2D2D2D)
        self.layer.borderColor = UIColor(named: ColorName_27AE60)?.cgColor
        self.layer.cornerRadius = 12
        self.button.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
        self.label.font = UIFont.systemFont(ofSize: MessageReactionItemView.fontSize, weight: .medium)
        self.label.textColor = UIColor(named: ColorName_BDBDBD)
        self.addSubview(self.button)
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        
        self.label.snp.makeConstraints { make in
            make.left.equalTo(self.imageView.snp.right).offset(3)
            make.centerY.equalTo(self)
            make.right.equalTo(8)
        }
    }
    
    func setReaction(_ reaction: String, count: UInt, isAdded: Bool) {
        self.label.text = "\(count)"
        self.imageView.image = UIImage(named: reaction)
        if isAdded {
            self.backgroundColor = UIColor(named: ColorName_16743C)
            self.layer.borderWidth = 1
            self.label.textColor = UIColor.white
        } else {
            self.backgroundColor = UIColor(named: ColorName_2D2D2D)
            self.layer.borderWidth = 0
            self.label.textColor = UIColor(named: ColorName_BDBDBD)
        }
    }
    
    @objc private func clickAction() {
        self.clickHandle?(self)
    }
}
