//
//  MessageItemCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/29.
//

import UIKit
import Kingfisher

class MessageItemCell: UICollectionViewCell {

    @IBOutlet private weak var bgImageView: UIImageView!
    @IBOutlet private weak var itemImageView: UIImageView!
    @IBOutlet private weak var unreadCountView: UIView!
    @IBOutlet private weak var unreadCountLabel: UILabel!
    
    private var downloadTask: DownloadTask?
    
    var image: UIImage? {
        didSet {
            self.downloadTask?.cancel()
            self.itemImageView.image = self.image
        }
    }
    
    var imageUrl: String? {
        didSet {
            self.downloadTask?.cancel()
            self.downloadTask = self.itemImageView.setImage(withUrl: imageUrl, placeholder: "server_head_placeholder")
        }
    }
    
    var bgShow: Bool = false {
        didSet {
            self.bgImageView.isHidden = !self.bgShow
        }
    }
    
    var unreadCount: Int32? {
        didSet {
            if let count = self.unreadCount, count > 0 {
                self.unreadCountView.isHidden = false
                let text = count > 99 ? "99+" : "\(count)"
                self.unreadCountLabel.text = text
            } else {
                self.unreadCountView.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgImageView.isHidden = !self.bgShow
    }
}
