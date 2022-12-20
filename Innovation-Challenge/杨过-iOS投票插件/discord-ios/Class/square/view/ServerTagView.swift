//
//  ServerTagView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import UIKit

class ServerTagView: UIView {

    private static let fontSize: CGFloat = 10
    
    private let imageView = UIImageView(image: UIImage(named: "server_tag_icon"))
    private let label = UILabel()
    private var deleteButton = UIButton(type: .custom)
    
    var showDelete: Bool {
        didSet {
            self.label.snp.updateConstraints { make in
                if self.showDelete {
                    make.right.equalTo(self).offset(-18)
                } else {
                    make.right.equalTo(self)
                }
            }
            self.imageView.snp.updateConstraints { make in
                if self.showDelete {
                    make.width.height.equalTo(16)
                } else {
                    make.width.height.equalTo(12)
                }
            }
            self.deleteButton.isHidden = !self.showDelete
        }
    }
    
    public class func minWidth(showDelete: Bool) -> CGFloat {
        if showDelete {
            return 54
        } else {
            return 36
        }
    }
    
    public var maxWidth: CGFloat {
        guard let serverTag = self.serverTag, let font = self.label.font else {
            return 16
        }
        let attrStr = NSAttributedString(string: serverTag, attributes: [
            .font: font
        ])
        
        let tagW = attrStr.boundingRect(with: CGSize(width: 1000, height: 1000), options: .usesFontLeading, context: nil).width
        if showDelete {
            return 34 + ceil(tagW) // 16 + ceil(tagW) + 2 + 16
        } else {
            return 12 + ceil(tagW)
        }
    }
    
    public var deleteHandle: ((_ tag: String?) -> Void)?
    
    override init(frame: CGRect) {
        self.showDelete = false
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        self.showDelete = false
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        self.selfInit()
    }
    
    public var serverTag: String? {
        didSet {
            self.label.text = serverTag
        }
    }
    
    private func selfInit() {
        self.backgroundColor = UIColor.clear
        self.imageView.alpha = 0.8
        self.label.font = UIFont.systemFont(ofSize: ServerTagView.fontSize)
        self.label.textColor = UIColor(white: 1, alpha: 0.8)
        self.deleteButton.setBackgroundImage(UIImage(named: "server_tag_delete"), for: .normal)
        self.deleteButton.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        self.addSubview(self.imageView)
        self.addSubview(self.label)
        self.addSubview(self.deleteButton)

        self.imageView.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.centerY.left.equalTo(self)
        }
        self.label.snp.makeConstraints { make in
            make.left.equalTo(self.imageView.snp.right)
            make.centerY.equalTo(self)
            if self.showDelete {
                make.right.equalTo(self).offset(16)
            } else {
                make.right.equalTo(self)
            }
        }
        self.deleteButton.snp.makeConstraints { make in
            make.width.height.equalTo(16)
            make.right.centerY.equalTo(self)
        }
        self.deleteButton.isHidden = !self.showDelete
    }
    
    @objc private func deleteAction() {
        self.deleteHandle?(self.serverTag)
    }
    
}
