//
//  SquareCollectionViewCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import UIKit
import HyphenateChat
import Kingfisher

class SquareCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var bgImageView: UIImageView!
    @IBOutlet private weak var headImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var tagListView: ServerTagListView!
    
    private var downloadTask: DownloadTask?
    
    public var server: EMCircleServer? {
        didSet {
            self.downloadTask?.cancel()
            self.downloadTask = self.headImageView.setImage(withUrl: server?.icon, placeholder: "server_head_placeholder")
            self.nameLabel.text = server?.name
            self.descLabel.text = server?.desc
            let index = (self.server?.serverId.last?.asciiValue ?? 0) % 9 + 1
            self.bgImageView.image = UIImage(named: "cover0\(index)")
            self.tagListView.setTags(server?.tags, itemHeight: self.tagListView.bounds.height)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgImageView.image = UIImage(named: "server_bg")
    }
}
