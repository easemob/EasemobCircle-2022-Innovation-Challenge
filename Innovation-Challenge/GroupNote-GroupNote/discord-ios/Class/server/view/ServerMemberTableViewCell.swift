//
//  ServerMemberTableViewCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/30.
//

import UIKit
import HyphenateChat
import Kingfisher

class ServerMemberTableViewCell: UITableViewCell {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var onlineView: UserStatusView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var muteImageView: UIImageView!
    @IBOutlet private weak var roleLabel: UILabel!
    
    private var downloadTask: DownloadTask?
    
    func setUserInfo(userId: String, userInfo: EMUserInfo?, member: EMCircleUser?) {
        self.downloadTask?.cancel()
        switch member?.role {
        case .owner:
            self.roleLabel.isHidden = false
            self.roleLabel.backgroundColor = UIColor(named: ColorName_27AE60)
            self.roleLabel.text = "创建者"
        case .moderator:
            self.roleLabel.isHidden = false
            self.roleLabel.backgroundColor = UIColor(named: ColorName_6C6FF8)
            self.roleLabel.text = "管理员"
        default:
            self.roleLabel.isHidden = true
        }
        if let showname = userInfo?.showname, showname.count > 0 {
            self.nameLabel.text = showname
        } else {
            self.nameLabel.text = userId
        }
        self.downloadTask = self.iconImageView.setImage(withUrl: userInfo?.avatarUrl, placeholder: "head_placeholder")
    }
    
    var state: UserStatusView.Status = .offline {
        didSet {
            self.onlineView.status = self.state
        }
    }
    
    var isMute: Bool = false {
        didSet {
            self.muteImageView.isHidden = !isMute
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        self.backgroundColor = UIColor(named: highlighted ? ColorName_2B2B2B : ColorName_1F1F1F)
    }
}
