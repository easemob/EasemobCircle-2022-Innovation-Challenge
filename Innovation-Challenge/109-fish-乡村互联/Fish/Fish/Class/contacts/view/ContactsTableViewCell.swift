//
//  ContactsTableViewCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/27.
//

import UIKit
import HyphenateChat
import Kingfisher

class ContactsTableViewCell: UITableViewCell {

    enum ShowType {
        case chat(chatHandle: (() -> Void)?)
        case add(addHandle: (() -> Void)?)
        case added
        case adding
        case invite(isInvited: Bool, handle: (() -> Void)?)
        case inviteCMD(acceptHandle: (() -> Void)?, refuseHandle: (() -> Void)?)
    }
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var onlineView: UserStatusView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var chatButton: UIButton!
    @IBOutlet private weak var refuseButton: UIButton!
    @IBOutlet private weak var rightButton: UIButton!
    
    private var downloadtask: DownloadTask?
    
    var userId: String? {
        didSet {
            guard let userId = self.userId else {
                self.userInfo = nil
                self.online = false
                return
            }
            self.nameLabel.text = userId
            self.userInfo = UserInfoManager.share.userInfo(userId: userId)
            self.online = UserOnlineManager.shared.checkIsOnline(userId: userId)
        }
    }
    
    var userInfo: EMUserInfo? {
        didSet {
            self.downloadtask?.cancel()
            guard let userInfo = userInfo else {
                self.nameLabel.text = self.userId
                self.descLabel.text = nil
                self.avatarImageView.image = UIImage(named: "head_placeholder")
                return
            }

            self.nameLabel.text = userInfo.showname
//            self.descLabel.text = userInfo.userId
            self.downloadtask = self.avatarImageView.setImage(withUrl: userInfo.avatarUrl, placeholder: "head_placeholder")
        }
    }
    
    var showType: ShowType? {
        didSet {
            switch showType {
            case .chat(chatHandle: _):
                self.chatButton.isHidden = false
                self.refuseButton.isHidden = true
                self.rightButton.isHidden = true
            case .add(addHandle: _):
                self.chatButton.isHidden = true
                self.refuseButton.isHidden = true
                self.rightButton.isHidden = false
                self.rightButton.setTitle("添加", for: .normal)
                self.rightButton.backgroundColor = UIColor(named: ColorName_27AE60)
                self.rightButton.setTitleColor(UIColor(named: ColorName_F2F2F2), for: .normal)
            case .added:
                self.chatButton.isHidden = true
                self.refuseButton.isHidden = true
                self.rightButton.isHidden = false
                self.rightButton.setTitle("已添加", for: .normal)
                self.rightButton.backgroundColor = UIColor(named: ColorName_3E3F40)
                self.rightButton.setTitleColor(UIColor(named: ColorName_27AE60), for: .normal)
            case .adding:
                self.chatButton.isHidden = true
                self.refuseButton.isHidden = true
                self.rightButton.isHidden = false
                self.rightButton.setTitle("添加中", for: .normal)
                self.rightButton.backgroundColor = UIColor(named: ColorName_3E3F40)
                self.rightButton.setTitleColor(UIColor(named: ColorName_F2F2F2)?.withAlphaComponent(0.4), for: .normal)
            case .inviteCMD(acceptHandle: _, refuseHandle: _):
                self.chatButton.isHidden = true
                self.refuseButton.isHidden = false
                self.rightButton.isHidden = false
                self.rightButton.setTitle("接受", for: .normal)
            case .invite(isInvited: let isInvite, handle: _):
                self.chatButton.isHidden = true
                self.refuseButton.isHidden = true
                self.rightButton.isHidden = false
                if isInvite {
                    self.rightButton.setTitle("已发送", for: .normal)
                    self.rightButton.backgroundColor = UIColor.clear
                } else {
                    self.rightButton.setTitle("邀请", for: .normal)
                    self.rightButton.backgroundColor = UIColor(named: ColorName_27AE60)
                }
            default:
                self.chatButton.isHidden = true
                self.refuseButton.isHidden = true
                self.rightButton.isHidden = true
            }
        }
    }
    
    var online: Bool = false {
        didSet {
            self.onlineView.status = online ? .online : .offline
            self.descLabel.text = online ? "在线" : "离线"
        }
    }
    
    @IBAction func chatAction(_ sender: Any) {
        switch self.showType {
        case .chat(chatHandle: let handle):
            handle?()
        default:
            break
        }
    }
    
    @IBAction func refuseAction(_ sender: Any) {
        switch self.showType {
        case .inviteCMD(acceptHandle: _, refuseHandle: let handle):
            handle?()
        default:
            break
        }
    }
    
    @IBAction func rightButtonAction(_ sender: Any) {
        switch self.showType {
        case .add(addHandle: let handle):
            handle?()
        case .inviteCMD(acceptHandle: let handle, refuseHandle: _):
            handle?()
        case .invite(isInvited: let isInvited, handle: let handle):
            if !isInvited {
                handle?()
            }
        default:
            break
        }
    }
}
