//
//  MessageVideoCell.swift
//  discord-ios
//
//  Created by mac on 2022/12/23.
//

import Foundation
import HyphenateChat
import Kingfisher
import SnapKit

class MessageVideoCell: MessageBaseCell {

    private let contentImageView = UIImageView()
    private let button = UIButton(type: .custom)
    private let buttonPlay = UIButton(type: .custom)
    
    private var downloadTask: DownloadTask?
    
    public var didClickHandle: ((_ image: UIImage?) -> Void)?
    
    override func setupContentView(_ view: UIView) {
        self.button.addTarget(self, action: #selector(onClickAction), for: .touchUpInside)
        self.contentImageView.contentMode = .scaleAspectFill
        view.addSubview(self.contentImageView)
        self.contentImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalTo(0)
            make.width.height.equalTo(100)
        }
        self.button.backgroundColor = .black.withAlphaComponent(0.3)
        view.addSubview(self.button)
        self.button.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(self.contentImageView)
        }
        
        self.buttonPlay.setImage(UIImage(named: "play_icon"), for: .normal)
        self.buttonPlay.addTarget(self, action: #selector(onClickPlayAction), for: .touchUpInside)
        view.addSubview(self.buttonPlay)
        self.buttonPlay.snp.makeConstraints { make in
            make.center.equalTo(self.contentImageView)
            make.height.width.equalTo(44)
        }
    }
    @objc
    func onClickPlayAction() {
        self.didClickHandle?(self.contentImageView.image)
    }
    
    override func update(_ message: EMChatMessage?) {
        self.downloadTask?.cancel()
        if let body = message?.body as? EMVideoMessageBody {
            var scale: CGFloat = 1
            if body.thumbnailSize.width > 0 {
                scale = body.thumbnailSize.height / body.thumbnailSize.width
            }
            self.contentImageView.snp.updateConstraints { make in
                make.width.equalTo(200)
                make.height.equalTo(200 * scale)
            }
            if let thumbnailLocalPath = body.thumbnailLocalPath, thumbnailLocalPath.count > 0, let image = UIImage(contentsOfFile: thumbnailLocalPath) {
                self.contentImageView.image = image
            } else if let localPath = body.localPath, localPath.count > 0, let image = UIImage(contentsOfFile: localPath) {
                self.contentImageView.image = image
            } else {
                self.downloadTask = self.contentImageView.setImage(withUrl: body.thumbnailRemotePath)
            }
        }
    }
    
    @objc private func onClickAction() {
        self.didClickHandle?(self.contentImageView.image)
    }
    
    override func cellHeight(width: CGFloat) -> CGFloat {
        var height = super.cellHeight(width: width)
        if let body = message?.body as? EMVideoMessageBody {
            var scale: CGFloat = 1
            if body.thumbnailSize.width > 0 {
                scale = body.thumbnailSize.height / body.thumbnailSize.width
            }
            height += 200 * scale
        }
        return height
    }
}
