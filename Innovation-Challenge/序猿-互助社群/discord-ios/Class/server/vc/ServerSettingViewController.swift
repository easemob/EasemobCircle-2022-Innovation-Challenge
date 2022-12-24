//
//  ServerSettingViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/29.
//

import UIKit
import HyphenateChat
import SnapKit
import MJRefresh

class ServerSettingViewController: UIViewController {

    @IBOutlet private weak var inviteButton: ServerEditItemButton!
    @IBOutlet private weak var createChannelButton: ServerEditItemButton!
    @IBOutlet private weak var settingButton: ServerEditItemButton!
    @IBOutlet private weak var tableView: UITableView!
    
    private let serverId: String
    private var result: EMCursorResult<EMCircleUser>?
    private var role: EMCircleUserRole?
    
    private let userOnlineStateCache = UserOnlineStateCache()
    
    init(serverId: String) {
        self.serverId = serverId
        super.init(nibName: "ServerSettingViewController", bundle: nil)
        self.modalPresentationStyle = .popover
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "社区设置"
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "more_white"), for: .normal)
        btn.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ServerMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        EMClient.shared().circleManager?.add(serverDelegate: self, queue: nil)
        EMClient.shared().addMultiDevices(delegate: self, queue: nil)
        
        if let currentUserId = EMClient.shared().currentUsername, currentUserId.count > 0 {
            ServerRoleManager.shared.queryServerRole(serverId: self.serverId) { [weak self] role in
                guard let self = self else {
                    return
                }
                self.role = role
                switch role {
                case .owner:
                    break
                case .moderator:
                    self.createChannelButton.isHidden = true
                    self.inviteButton.snp.updateConstraints({ make in
                        make.right.equalTo(self.settingButton.snp.left).offset(-30)
                    })
                default:
                    self.createChannelButton.isHidden = true
                    self.settingButton.isHidden = true
                    self.inviteButton.snp.updateConstraints({ make in
                        make.right.equalTo(0)
                    })
                }
            }
        }
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadData(refresh: true)
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadData(refresh: false)
        })
        self.tableView.mj_header?.beginRefreshing()
    }
    
    private func loadData(refresh: Bool) {
        let cursor = refresh ? nil : self.result?.cursor
        EMClient.shared().circleManager?.fetchServerMembers(self.serverId, limit: 20, cursor: cursor) { [weak self] result, error in
            guard let self = self else {
                return
            }
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
                return
            }
            
            var userIds: [String] = []
            if let list = result?.list {
                for i in list {
                    if let userId = i.userId {
                        userIds.append(userId)
                    }
                }
            }
            
            if refresh || self.result == nil {
                self.result = result
            } else if let result = result {
                self.result?.append(result)
            }
            self.tableView.mj_header?.endRefreshing()
            if (result?.list?.count ?? 0) < 20 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                self.tableView.mj_footer?.isHidden = true
            } else {
                self.tableView.mj_footer?.endRefreshing()
                self.tableView.mj_footer?.isHidden = false
            }
            self.tableView.reloadData()
            
            self.userOnlineStateCache.refresh(members: userIds) { [weak self] in
                self?.tableView.reloadData()
            }
            UserInfoManager.share.queryUserInfo(userIds: userIds) { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc private func moreAction(_ sender: UIButton) {
        let vc = BubbleMenuView(baseView: sender)
        if self.role == .owner {
            vc.addMenuItem(image: UIImage(named: "server_delete")!, title: "解散社区") {
                let serverName = ServerInfoManager.shared.getServerInfo(serverId: self.serverId)?.name ?? ""
                let vc = UIAlertController(title: "解散社区", message: "确认解散社区\(serverName)？本操作不可撤销。", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "取消", style: .default))
                vc.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
                    EMClient.shared().circleManager?.destroyServer(self.serverId) { error in
                        if let error = error {
                            Toast.show(error.errorDescription, duration: 2)
                        } else {
                            Toast.show("解散成功", duration: 2)
                            ServerInfoManager.shared.remove(serverId: self.serverId)
                            NotificationCenter.default.post(name: EMCircleDidDestroyServer, object: self.serverId)
                            self.dismiss(animated: true)
                        }
                    }
                }))
                self.present(vc, animated: true)
            }
        } else {
            vc.addMenuItem(image: UIImage(named: "server_exit")!, title: "退出社区") {
                let serverName = ServerInfoManager.shared.getServerInfo(serverId: self.serverId)?.name ?? ""
                let vc = UIAlertController(title: "退出社区", message: "确认退出社区\(serverName)？", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "取消", style: .default))
                vc.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
                    EMClient.shared().circleManager?.leaveServer(self.serverId) { error in
                        if let error = error {
                            Toast.show(error.errorDescription, duration: 2)
                        } else {
                            Toast.show("退出成功", duration: 2)
                            NotificationCenter.default.post(name: EMCircleDidExitedServer, object: self.serverId)
                            self.dismiss(animated: true)
                        }
                    }
                }))
                self.present(vc, animated: true)
            }
        }
        vc.show()
    }
    
    @IBAction func inviteAction() {
        let vc = FriendInviteViewController()
        vc.didInviteHandle = { userId, complete in
            EMClient.shared().circleManager?.inviteUserToServer(serverId: self.serverId, userId: userId, welcome: nil) { error in
                if let error = error {
//                    if error.code == .repeatedOperation {
//                        Toast.show("该用户已加入社区", duration: 2)
//                    } else {
//                        Toast.show(error.errorDescription, duration: 2)
//                    }
                    complete(false)
                } else {
                    Toast.show("邀请成功", duration: 2)
                    let server = ServerInfoManager.shared.getServerInfo(serverId: self.serverId)
                    let body = EMCustomMessageBody(event: "invite_server", customExt: [
                        "server_id": self.serverId,
                        "server_name": server?.name ?? "",
                        "icon": server?.icon ?? "",
                        "desc": server?.desc ?? ""
                    ])
                    let message = EMChatMessage(conversationID: userId, from: EMClient.shared().currentUsername!, to: userId, body: body, ext: nil)
                    EMClient.shared().chatManager?.send(message, progress: nil)
                    complete(true)
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func createChannelAction() {
        let vc = ChannelCreateViewController(showType: .create(serverId: self.serverId))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func settingAction() {
        let vc = ServerEditViewController(serverId: self.serverId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        EMClient.shared().circleManager?.remove(serverDelegate: self)
        EMClient.shared().remove(self)
    }
}

extension ServerSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ServerMemberTableViewCell {
            let member = self.result?.list?[indexPath.row] as? EMCircleUser
            if let userId = member?.userId {
                cell.setUserInfo(userId: userId, userInfo: UserInfoManager.share.userInfo(userId: userId), member: member)
                cell.state = self.userOnlineStateCache.getUserStatus(userId) ?? .offline
            }
        }
        return cell
    }
}

extension ServerSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userInfo = self.result?.list?[indexPath.row] as? EMCircleUser, let role = self.role, let userId = userInfo.userId, userId != EMClient.shared().currentUsername {
            let onlineState = self.userOnlineStateCache.getUserStatus(userId) ?? .offline
            let vc = ServerUserMenuViewController(userId: userId, showType: .server(serverId: self.serverId), role: role, targetRole: userInfo.role, onlineState: onlineState)
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
                self.onMemberRemoved(fromServer: self.serverId, members: [userId])
            }
            self.present(vc, animated: true)
        }
    }
}

extension ServerSettingViewController: EMCircleManagerServerDelegate {
    func onServerDestroyed(_ serverId: String, initiator: String) {
        if serverId == self.serverId {
            Toast.show("社区被解散", duration: 2)
            self.dismiss(animated: true)
        }
    }
    
    func onMemberLeftServer(_ serverId: String, member: String) {
        self.onMemberLeft(serverId: serverId, members: [member])
    }
    
    func onMemberRemoved(fromServer serverId: String, members: [String]) {
        self.onMemberLeft(serverId: serverId, members: members)
    }
    
    private func onMemberLeft(serverId: String, members: [String]) {
        guard serverId == self.serverId, var list = self.result?.list else {
            return
        }
        var memberSet = Set<String>()
        for member in members {
            memberSet.insert(member)
        }
        var deleteIndexPaths: [IndexPath] = []
        for i in (0..<list.count).reversed() {
            if let userId = list[i].userId, memberSet.contains(userId) {
                list.remove(at: i)
                deleteIndexPaths.append(IndexPath(row: i, section: 0))
                if members.count == deleteIndexPaths.count {
                    break
                }
            }
        }
        self.result?.list = list
        if deleteIndexPaths.count > 0 {
            self.tableView.performBatchUpdates {
                self.tableView.deleteRows(at: deleteIndexPaths, with: .none)
            }
        }
    }
}

extension ServerSettingViewController: EMMultiDevicesDelegate {
    func multiDevicesCircleServerEventDidReceive(_ aEvent: EMMultiDevicesEvent, serverId: String, ext aExt: Any?) {
        guard serverId == self.serverId else {
            return
        }
        switch aEvent {
        case .circleServerRemoveUser:
            if let members = aExt as? [String] {
                self.onMemberLeft(serverId: self.serverId, members: members)
            }
        default:
            break
        }
    }
}
