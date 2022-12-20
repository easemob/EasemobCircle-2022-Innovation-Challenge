//
//  ChannelSettingViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/5.
//

import UIKit
import HyphenateChat
import MJRefresh
import SnapKit

class ChannelSettingViewController: UIViewController {

    @IBOutlet private weak var inviteButton: ServerEditItemButton!
    @IBOutlet private weak var threadButton: ServerEditItemButton!
    @IBOutlet private weak var settingButton: ServerEditItemButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private let serverId: String
    private let channelId: String
    private let userOnlineStateCache = UserOnlineStateCache()
    private var muteStateMap: [String: NSNumber]?
    
    private var result: EMCursorResult<EMCircleUser>?
    private var role: EMCircleUserRole?
    
    init(serverId: String, channelId: String) {
        self.serverId = serverId
        self.channelId = channelId
        super.init(nibName: nil, bundle: nil)
    }
    
    var didDeleteHandle: (() -> Void)?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "频道设置"
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ServerMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadData(refresh: true)
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadData(refresh: false)
        })
        
        EMClient.shared().circleManager?.add(channelDelegate: self, queue: nil)
        EMClient.shared().addMultiDevices(delegate: self, queue: nil)
        
        self.tableView.mj_header?.beginRefreshing()
        
        EMClient.shared().circleManager?.fetchSelfServerRole(self.serverId) { [weak self] role, error in
            guard let self = self else {
                return
            }
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            }
            self.role = role
            switch role {
            case .owner:
                EMClient.shared().circleManager?.fetchChannelDetail(self.serverId, channelId: self.channelId) { channel, error in
                    if let error = error {
                        Toast.show(error.errorDescription, duration: 2)
                    } else if let channel = channel, !channel.isDefault {
                        self.createMoreButton()
                    }
                }
                self.loadMuteList()
            case .moderator:
                self.loadMuteList()
            default:
                self.settingButton.isHidden = true
                self.threadButton.snp.updateConstraints { make in
                    make.right.equalTo(0)
                }
            }
        }
    
    }
    
    private func createMoreButton() {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "more_white"), for: .normal)
        btn.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
    }
    
    @objc private func moreAction(_ sender: UIButton) {
        EMClient.shared().circleManager?.fetchSelfServerRole(self.serverId) { role, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                if role == .owner {
                    let v = BubbleMenuView(baseView: sender)
                    v.addMenuItem(image: UIImage(named: "server_delete")!, title: "删除频道") {
                        let vc = UIAlertController(title: "删除频道", message: "确认删除频道？本操作不可撤销。", preferredStyle: .alert)
                        vc.addAction(UIAlertAction(title: "取消", style: .default))
                        vc.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { _ in
                            EMClient.shared().circleManager?.destroyChannel(self.serverId, channelId: self.channelId) { error in
                                if let error = error {
                                    Toast.show(error.errorDescription, duration: 2)
                                } else {
                                    Toast.show("删除频道成功", duration: 2)
                                    NotificationCenter.default.post(name: EMCircleDidDestroyChannel, object: (self.serverId, self.channelId))
                                    self.dismiss(animated: true) {
                                        self.didDeleteHandle?()
                                    }
                                }
                            }
                        }))
                        self.present(vc, animated: true)
                    }
                    v.show()
                } else {
                    let v = BubbleMenuView(baseView: sender)
                    v.addMenuItem(image: UIImage(named: "server_exit")!, title: "退出频道") {
                        let vc = UIAlertController(title: "退出频道", message: "确认退出频道？", preferredStyle: .alert)
                        vc.addAction(UIAlertAction(title: "取消", style: .default))
                        vc.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { _ in
                            EMClient.shared().circleManager?.leaveChannel(self.serverId, channelId: self.channelId) { error in
                                if let error = error {
                                    Toast.show(error.errorDescription, duration: 2)
                                } else {
                                    Toast.show("退出频道成功", duration: 2)
                                    NotificationCenter.default.post(name: EMCircleDidExitedChannel, object: (self.serverId, self.channelId))
                                    self.dismiss(animated: true) {
                                        self.didDeleteHandle?()
                                    }
                                }
                            }
                        }))
                        self.present(vc, animated: true)
                    }
                    v.show()
                }
            }
        }
    }
    
    @IBAction func inviteAction() {
        let vc = FriendInviteViewController()
        vc.didInviteHandle = { userId, complete in
            EMClient.shared().circleManager?.inviteUserToChannel(serverId: self.serverId, channelId: self.channelId, userId: userId, welcome: nil) { error in
                if let error = error {
//                    if error.code == .repeatedOperation {
//                        Toast.show("该用户已加入频道", duration: 2)
//                    } else {
                    Toast.show(error.errorDescription, duration: 2)
//                    }
                    complete(false)
                } else {
                    Toast.show("邀请成功", duration: 2)
                    EMClient.shared().circleManager?.fetchChannelDetail(self.serverId, channelId: self.channelId) { channel, _ in
                        let server = ServerInfoManager.shared.getServerInfo(serverId: self.serverId)
                        let body = EMCustomMessageBody(event: "invite_channel", customExt: [
                            "server_id": self.serverId,
                            "server_name": server?.name ?? "",
                            "icon": server?.icon ?? "",
                            "channel_id": self.channelId,
                            "desc": channel?.desc ?? "",
                            "channel_name": channel?.name ?? ""
                        ])
                        let message = EMChatMessage(conversationID: userId, from: EMClient.shared().currentUsername!, to: userId, body: body, ext: nil)
                        EMClient.shared().chatManager?.send(message, progress: nil)
                    }
                    complete(true)
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func threadAction() {
        let vc = ThreadListViewController(chatType: .channel(serverId: self.serverId, channelId: self.channelId))
        if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tabBarController.dismiss(animated: true) {
                (tabBarController.selectedViewController as? UINavigationController)?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func editAction() {
        let vc = ChannelCreateViewController(showType: .update(serverId: self.serverId, channelId: self.channelId))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func loadData(refresh: Bool) {
        let cursor = refresh ? nil : self.result?.cursor
        EMClient.shared().circleManager?.fetchChannelMembers(self.serverId, channelId: self.channelId, limit: 20, cursor: cursor) { result, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                if refresh || self.result == nil {
                    self.result = result
                } else if let result = result {
                    self.result?.append(result)
                }
            }
            self.tableView.mj_header?.endRefreshing()
            if let cursor = result?.cursor, cursor.count > 0 {
                self.tableView.mj_footer?.endRefreshing()
                self.tableView.mj_footer?.isHidden = false
            } else {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                self.tableView.mj_footer?.isHidden = true
            }
            self.tableView.reloadData()
            
            var userIds: [String] = []
            if let list = result?.list {
                for i in list {
                    if let userId = i.userId {
                        userIds.append(userId)
                    }
                }
            }
            self.userOnlineStateCache.refresh(members: userIds) { [weak self] in
                self?.tableView.reloadData()
            }
            UserInfoManager.share.queryUserInfo(userIds: userIds) { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    private func loadMuteList() {
        EMClient.shared().circleManager?.fetchChannelMuteUsers(self.serverId, channelId: self.channelId, completion: { result, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                self.muteStateMap = result
                self.tableView.reloadData()
            }
        })
    }
    
    deinit {
        EMClient.shared().circleManager?.remove(channelDelegate: self)
        EMClient.shared().remove(self)
    }
}

extension ChannelSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ServerMemberTableViewCell {
            let circleUser = self.result?.list?[indexPath.row] as? EMCircleUser
            if let userId = circleUser?.userId {
                let userInfo = UserInfoManager.share.userInfo(userId: userId)
                cell.setUserInfo(userId: userId, userInfo: userInfo, member: circleUser)
                cell.state = self.userOnlineStateCache.getUserStatus(userId) ?? .offline
                cell.isMute = self.isMute(userId: userId)
            }
        }
        return cell
    }
    
    private func isMute(userId: String) -> Bool {
        if let duration = self.muteStateMap?[userId], TimeInterval(duration.uint64Value) / 1000 > Date().timeIntervalSince1970 {
            return true
        } else {
            return false
        }
    }
}

extension ChannelSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let circleUser = self.result?.list?[indexPath.row] as? EMCircleUser else {
            return
        }
        guard let userId = circleUser.userId, let selfRole = self.role else {
            return
        }
        if userId == EMClient.shared().currentUsername {
            return
        }
        let onlineState = self.userOnlineStateCache.getUserStatus(userId) ?? .offline
        let vc = ServerUserMenuViewController(userId: userId, showType: .channel(serverId: self.serverId, channelId: self.channelId), role: selfRole, targetRole: circleUser.role, onlineState: onlineState, isMute: self.isMute(userId: userId))
        vc.didRoleChangeHandle = { userId, role in
            if let list = self.result?.list {
                for i in 0..<list.count where list[i].userId == userId {
                    list[i].role = role
                    self.tableView.performBatchUpdates {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    break
                }
            }
        }
        vc.didKickHandle = { userId in
            self.onMemberLeft(channelId: self.channelId, member: userId)
        }
        vc.didMuteHandle = { userId, duration in
            if let duration = duration {
                let number = (TimeInterval(duration) + Date().timeIntervalSince1970) * 1000
                self.muteStateMap?[userId] = NSNumber(value: number)
            } else {
                self.muteStateMap?[userId] = nil
            }
            if let list = self.result?.list {
                for i in 0..<list.count where list[i].userId == userId {
                    self.tableView.performBatchUpdates {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    break
                }
            }
        }
        self.present(vc, animated: true)
    }
}

extension ChannelSettingViewController: EMCircleManagerChannelDelegate {
    func onMemberLeftChannel(_ serverId: String, channelId: String, member: String) {
        self.onMemberLeft(channelId: channelId, member: member)
    }
    
    func onMemberRemoved(fromChannel serverId: String, channelId: String, member: String, initiator: String) {
        self.onMemberLeft(channelId: channelId, member: member)
    }
    
    func onChannelDestroyed(_ serverId: String, channelId: String, initiator: String) {
        if channelId == self.channelId {
            Toast.show("频道已经被解散", duration: 2)
            self.dismiss(animated: true)
        }
    }
    
    private func onMemberLeft(channelId: String, member: String) {
        guard channelId == self.channelId, var list = self.result?.list else {
            return
        }
        for i in 0..<list.count where list[i].userId == member {
            list.remove(at: i)
            self.result?.list = list
            self.tableView.performBatchUpdates {
                self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .none)
            }
            break
        }
    }
    
    func onMemberMuteChange(inChannel serverId: String, channelId: String, muted isMuted: Bool, members: [String]) {
        if channelId == self.channelId {
            self.loadMuteList()
        }
    }
}

extension ChannelSettingViewController: EMMultiDevicesDelegate {
    func multiDevicesCircleChannelEventDidReceive(_ aEvent: EMMultiDevicesEvent, channelId: String, ext aExt: Any?) {
        guard serverId == self.serverId else {
            return
        }
        switch aEvent {
        case .circleServerRemoveUser:
            if let member = (aExt as? [String])?.first {
                self.onMemberLeft(channelId: self.channelId, member: member)
            }
        case .circleChannelDestroy:
            Toast.show("频道被销毁", duration: 2)
            self.dismiss(animated: true)
        case .circleChannelAddMute, .circleChannelRemoveMute:
            if channelId == self.channelId {
                self.loadMuteList()
            }
        default:
            break
        }
    }
}
