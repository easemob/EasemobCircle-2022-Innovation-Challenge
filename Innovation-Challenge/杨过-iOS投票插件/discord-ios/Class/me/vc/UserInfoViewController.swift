//
//  UserInfoViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import UIKit
import HyphenateChat
import Kingfisher

class UserInfoViewController: UIViewController {
    
    public enum ShowType {
        case me
        case other(userId: String)
        
        var userId: String? {
            switch self {
            case .me:
                return EMClient.shared().currentUsername
            case .other(userId: let userId):
                return userId
            }
        }
    }
    
    @IBOutlet private weak var placeholderImageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var mineLabel: UILabel!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var headIconImageView: UIImageView!
    @IBOutlet private weak var nicknameLabel: UILabel!
    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var settingButton: UIButton!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var addContactButton: UIButton!
    @IBOutlet private weak var chatButton: UIButton!
    @IBOutlet private weak var statusView: UserStatusView!
    
    private var showType: ShowType
    private var userInfo: EMUserInfo? {
        didSet {
            self.nicknameLabel.text = self.userInfo?.showname
            self.headIconImageView.setImage(withUrl: self.userInfo?.avatarUrl, placeholder: "head_placeholder")
        }
    }
    
    init(showType: ShowType) {
        self.showType = showType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backButton.isHidden = self.navigationController?.viewControllers.count ?? 0 <= 1
        switch self.showType {
        case .me:
            self.addContactButton.isHidden = true
            self.chatButton.isHidden = true
            self.settingButton.isHidden = false
            self.moreButton.isHidden = false
            self.mineLabel.isHidden = !self.backButton.isHidden
            self.statusView.status = .online
            NotificationCenter.default.addObserver(self, selector: #selector(onRecvCurrentUserInfoChangeNotification(notification:)), name: EMCurrentUserInfoUpdate, object: nil)
        case .other(userId: let value):
            self.addContactButton.isHidden = true
            self.chatButton.isHidden = false
            self.settingButton.isHidden = true
            self.moreButton.isHidden = true
            self.mineLabel.isHidden = true
            if let contacts = EMClient.shared().contactManager?.getContacts(), contacts.contains(value) {
                self.moreButton.isHidden = false
                self.chatButton.snp.updateConstraints { make in
                    make.left.equalTo(24)
                }
            } else {
                self.addContactButton.isHidden = false
            }
            self.placeholderImageViewBottomConstraint.constant = 88
            
            self.statusView.status = .offline
            EMClient.shared().presenceManager?.fetchPresenceStatus([value]) { presences, error in
                DispatchQueue.main.async {
                    if let error = error {
                        Toast.show(error.errorDescription, duration: 2)
                    } else if let presences = presences {
                        for presence in presences where presence.publisher == value {
                            self.statusView.status = presence.userStatus
                            break
                        }
                    }
                }
            }
        }
        let userId = self.showType.userId
        self.userIdLabel.text = userId
        if let userId = userId {
            UserInfoManager.share.queryUserInfo(userId: userId, loadCache: false) { userInfo, _ in
                if let userInfo = userInfo {
                    self.userInfo = userInfo
                    NotificationCenter.default.post(name: EMUserInfoUpdate, object: userInfo)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func settingAction() {
        let vc = MeSettingViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func moreAction(_ sender: UIButton) {
        let vc = BubbleMenuView(baseView: sender)
        switch self.showType {
        case .me:
            vc.addMenuItem(image: UIImage(named: "server_exit")!, title: "退出登录") {[unowned self] in
                let vc = UIAlertController(title: "退出登录", message: "确认退出吗？下次见哦！", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "取消", style: .default))
                vc.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
                    EMClient.shared().logout(true) { error in
                        if let e = error {
                            Toast.show(e.errorDescription, duration: 2)
                            return
                        }
                        (UIApplication.shared.delegate as? AppDelegate)?.switchToLogin()
                    }
                    ServerRoleManager.shared.clear()
                }))
                self.present(vc, animated: true)
            }
        case .other(userId: let userId):
            vc.addMenuItem(image: UIImage(named: "server_delete")!, title: "删除好友") {[unowned self] in
                let vc = UIAlertController(title: "删除好友", message: "确认删除 \(self.nicknameLabel.text ?? userId)？此操作不可撤回。", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "取消", style: .default))
                vc.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { _ in
                    EMClient.shared().contactManager?.deleteContact(userId, isDeleteConversation: false) { [weak self] _, error in
                        guard let self = self else {
                            return
                        }
                        if let error = error {
                            Toast.show(error.errorDescription, duration: 2)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }))
                self.present(vc, animated: true)
            }
        }
        vc.show()
    }
    
    @IBAction func addContactAction() {
        switch self.showType {
        case .other(userId: let userId):
            EMClient.shared().contactManager?.addContact(userId, message: nil) { _, error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    Toast.show("已发送好友申请", duration: 2)
                }
            }
        default:
            break
        }
    }
    
    @IBAction func chatAction() {
        switch self.showType {
        case .other(userId: let userId):
            let vc = ChatViewController(chatType: .single(userId: userId))
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    @objc private func onRecvCurrentUserInfoChangeNotification(notification: Notification) {
        if let userInfo = notification.object as? EMUserInfo {
            self.userInfo = userInfo
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
