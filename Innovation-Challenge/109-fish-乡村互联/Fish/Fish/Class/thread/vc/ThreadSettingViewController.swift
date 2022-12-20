//
//  ThreadSettingViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/11.
//

import UIKit
import HyphenateChat
import MJRefresh

class ThreadSettingViewController: UIViewController {

    @IBOutlet private weak var editButton: ServerEditItemButton!
    @IBOutlet private weak var lineView: UIView!
    @IBOutlet private weak var lineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    
    private let threadId: ThreadId
    private var result: EMCursorResult<NSString>?
    private var thread: EMChatThread?
    private var serverRole: EMCircleUserRole?
    private let userOnlineStateCache = UserOnlineStateCache()
    
    var didDeleteHandle: (() -> Void)?
    
    init(threadId: ThreadId) {
        self.threadId = threadId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "子区设置"
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ServerMemberTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadData(refresh: true)
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadData(refresh: false)
        })
        self.editButton.isHidden = true
        self.lineView.isHidden = true
        self.lineViewTopConstraint.constant = 40
        
        EMClient.shared().threadManager?.add(self, delegateQueue: nil)
        EMClient.shared().addMultiDevices(delegate: self, queue: nil)
        
        self.tableView.mj_header?.beginRefreshing()
        
        EMClient.shared().threadManager?.getChatThread(fromSever: self.threadId.threadId) { thread, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else if let thread = thread {
                self.thread = thread
            }
            
            if let threadId = self.threadId as? ChannelThreadId {
                EMClient.shared().circleManager?.fetchSelfServerRole(threadId.serverId) { role, _ in
                    self.serverRole = role
                    if role == .owner || EMClient.shared().currentUsername == self.thread?.owner {
                        self.editButton.isHidden = false
                        self.lineView.isHidden = false
                        self.lineViewTopConstraint.constant = 130
                    }
                    self.createMoreButton()
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
        self.showMoreBubbleView(canDestroy: self.serverRole == .owner, baseView: sender)
    }
    
    private func showMoreBubbleView(canDestroy: Bool, baseView: UIView) {
        guard let thread = self.thread else {
            return
        }
        let v = BubbleMenuView(baseView: baseView)
        if canDestroy {
            v.addMenuItem(image: UIImage(named: "server_delete")!, title: "删除子区") {
                let vc = UIAlertController(title: "删除子区", message: "确认删除子区 \(thread.threadName!)？本操作不可撤销。", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "取消", style: .default))
                vc.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { _ in
                    EMClient.shared().threadManager?.destroyChatThread(self.threadId.threadId) { error in
                        if let error = error {
                            Toast.show(error.errorDescription, duration: 2)
                        } else {
                            NotificationCenter.default.post(name: EMThreadDidDestroy, object: self.threadId)
                            self.dismiss(animated: true) {
                                self.didDeleteHandle?()
                            }
                        }
                    }
                }))
                self.present(vc, animated: true)
            }
        }
        v.addMenuItem(image: UIImage(named: "server_exit")!, title: "退出子区") {
            let vc = UIAlertController(title: "退出子区 \(thread.threadName!)", message: "确认退出子区？", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "取消", style: .default))
            vc.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { _ in
                EMClient.shared().threadManager?.leaveChatThread(self.threadId.threadId) { error in
                    if let error = error {
                        Toast.show(error.errorDescription, duration: 2)
                    } else {
                        NotificationCenter.default.post(name: EMThreadDidExited, object: self.threadId)
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
    
    private func loadData(refresh: Bool) {
        let cursor = refresh ? nil : self.result?.cursor
        EMClient.shared().threadManager?.getChatThreadMemberListFromServer(withId: self.threadId.threadId, cursor: cursor ?? "", pageSize: 20) { [weak self] result, error in
            guard let self = self else {
                return
            }
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
            
            if let userIds = result?.list as? [String] {
                self.userOnlineStateCache.refresh(members: userIds) { [weak self] in
                    self?.tableView.reloadData()
                }
                UserInfoManager.share.queryUserInfo(userIds: userIds) { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func settingAction() {
        let vc = ThreadEditViewController(threadId: self.threadId.threadId)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    deinit {
        EMClient.shared().threadManager?.remove(self)
        EMClient.shared().remove(self)
    }
}

extension ThreadSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ServerMemberTableViewCell {
            if let member = self.result?.list?[indexPath.row] as? String {
                cell.setUserInfo(userId: member, userInfo: UserInfoManager.share.userInfo(userId: member), member: nil)
                cell.state = self.userOnlineStateCache.getUserStatus(member) ?? .offline
            }
        }
        return cell
    }
}

extension ThreadSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userId = self.result?.list?[indexPath.row] as? String {
            let onlineState = self.userOnlineStateCache.getUserStatus(userId) ?? .offline
            let vc = ServerUserMenuViewController(userId: userId, showType: .thread(threadId: self.threadId.threadId), role: .user, targetRole: .user, onlineState: onlineState)
            self.present(vc, animated: true)
        }
    }
}

extension ThreadSettingViewController: EMThreadManagerDelegate {
    func onChatThreadDestroy(_ event: EMChatThreadEvent) {
        if event.chatThread.threadId == self.threadId.threadId {
            Toast.show("子区被销毁", duration: 2)
            self.dismiss(animated: true)
        }
    }
    
    func onUserKickOutOfChatThread(_ event: EMChatThreadEvent) {
        if event.chatThread.threadId == self.threadId.threadId {
            Toast.show("被从子区踢出", duration: 2)
            self.dismiss(animated: true)
        }
    }
}

extension ThreadSettingViewController: EMMultiDevicesDelegate {
    func multiDevicesChatThreadEventDidReceive(_ aEvent: EMMultiDevicesEvent, threadId aThreadId: String, ext aExt: Any?) {
        if aThreadId != self.threadId.threadId {
            return
        }
        switch aEvent {
        case .chatThreadDestroy:
            Toast.show("子区被销毁", duration: 2)
            self.dismiss(animated: true)
        case .chatThreadKick, .chatThreadLeave:
            Toast.show("子区已退出", duration: 2)
            self.dismiss(animated: true)
        default:
            break
        }
    }
}
