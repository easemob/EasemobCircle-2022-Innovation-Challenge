//
//  MessageFileCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/28.
//

import UIKit
import SnapKit
import HyphenateChat

class MessageFileCell: MessageBaseCell {

    private var fileView: MessageFileView?
    private let button = UIButton(type: .custom)
    
    public var didClickHandle: ((_ message: EMChatMessage?) -> Void)?
    
    override func setupContentView(_ view: UIView) {
        if let fileView = Bundle.main.loadNibNamed("MessageFileView", owner: nil)?.first as? MessageFileView {
            view.addSubview(fileView)
            fileView.snp.makeConstraints { make in
                make.left.top.bottom.right.equalTo(0)
                make.height.equalTo(64).priority(.high)
            }
            self.fileView = fileView
            
            self.button.addTarget(self, action: #selector(onClickAction), for: .touchUpInside)
            view.addSubview(self.button)
            self.button.snp.makeConstraints { make in
                make.left.right.top.bottom.equalTo(fileView)
            }
        }
    }
    
    override func update(_ message: EMChatMessage?) {
        guard let fileBody = message?.body as? EMFileMessageBody else {
            return
        }
        self.fileView?.fileName = fileBody.displayName
        self.fileView?.fileSize = fileBody.fileLength
    }
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        return super.cellHeight(width: width) + 64
    }
    
    @objc private func onClickAction() {
        self.didClickHandle?(self.message)
    }
}
