//
//  MessageServerViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/29.
//

import UIKit
import HyphenateChat
import PKHUD
import MJRefresh

class MessageServerViewController: UIViewController {

    @IBOutlet private weak var bgImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var tagListView: ServerTagListView!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    private let gradientLayer = CAGradientLayer()

    private var publicResult: EMCursorResult<EMCircleChannel>?
    private var privateResult: EMCursorResult<EMCircleChannel>?
    
    private var threadMap: [String: ([EMChatThread], String?)?] = [:]
    private var unfoldSet = Set<String>()
    private var channelFold = false
    
    var serverId: String {
        didSet {
            self.server = nil
            self.updateServerDetail(refresh: true)
            self.loadChannlsData(refresh: true)
            self.unfoldSet.removeAll()
        }
    }
    
    var server: EMCircleServer?
    
    init(serverId: String) {
        self.serverId = serverId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        self.gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        self.gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.6).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor
        ]
        self.bgImageView.layer.insertSublayer(self.gradientLayer, at: 0)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "MessageServerChannelHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "header")
        self.tableView.register(UINib(nibName: "MessageServerChannelCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [unowned self] in
            self.loadChannlsData(refresh: true)
        })
        self.tableView.mj_footer = MJRefreshAutoStateFooter(refreshingBlock: { [unowned self] in
            self.loadChannlsData(refresh: false)
        })
                
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateServerNotification(_:)), name: EMCircleDidUpdateServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didCreateChannelNotification(_:)), name: EMCircleDidCreateChannel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDestroyChannelNotification(_:)), name: EMCircleDidDestroyChannel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUpdateChannelNotification(_:)), name: EMCircleDidUpdateChannel, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didDestroyThreadNotification(_:)), name: EMThreadDidDestroy, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didJoinChannelNotification(_:)), name: EMCircleDidJoinChannel, object: nil)
        
        EMClient.shared().circleManager?.add(serverDelegate: self, queue: nil)
        EMClient.shared().circleManager?.add(channelDelegate: self, queue: nil)
        EMClient.shared().addMultiDevices(delegate: self, queue: nil)
        EMClient.shared().chatManager?.add(self, delegateQueue: nil)
        EMClient.shared().threadManager?.add(self, delegateQueue: nil)
        
        self.updateServerDetail(refresh: true)
        self.loadChannlsData(refresh: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer.frame = self.bgImageView.bounds
    }
    
    private func updateServerDetail(refresh: Bool = false) {
        let index = (self.serverId.last?.asciiValue ?? 0) % 9 + 1
        self.bgImageView.image = UIImage(named: "cover0\(index)")
        HUD.show(.progress, onView: self.view)
        ServerInfoManager.shared.getServerInfo(serverId: serverId, refresh: refresh) { [weak self] server, error in
            HUD.hide()
            guard let self = self else {
                return
            }
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
                return
            }
            if self.serverId != server?.serverId {
                return
            }
            self.server = server
            self.nameLabel.text = server?.name
            self.tagListView.setTags(server?.tags, itemHeight: self.tagListView.bounds.size.height)
            self.descLabel.text = server?.desc
            self.tableView.reloadData()
        }
    }

    @IBAction func addAction() {
        let vc = FriendInviteViewController()
        vc.didInviteHandle = { [weak self] userId, _ in
            guard let self = self else {
                return
            }
            EMClient.shared().circleManager?.inviteUserToServer(serverId: self.serverId, userId: userId, welcome: nil) { error in
                if let error = error {
//                    if error.code == .repeatedOperation {
//                        Toast.show("该用户已加入社区", duration: 2)
//                    } else {
//                        Toast.show(error.errorDescription, duration: 2)
//                    }
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
                }
            }
        }
        self.presentNavigationController(rootViewController: vc)
    }
    
    @IBAction func moreAction() {
        let vc = ServerSettingViewController(serverId: self.serverId)
        self.presentNavigationController(rootViewController: vc)
    }
    
    private func loadChannlsData(refresh: Bool) {
        let isPublic = self.publicResult == nil || (self.publicResult!.cursor != nil && self.publicResult!.cursor!.count > 0) || refresh
        if isPublic {
            EMClient.shared().circleManager?.fetchPublicChannels(inServer: self.serverId, limit: 20, cursor: refresh ? nil : self.publicResult?.cursor) { [weak self] result, error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let result = result {
                    if let publicResult = self.publicResult, !refresh {
                        publicResult.append(result)
                    } else {
                        self.publicResult = result
                    }
                    self.privateResult = nil
                    // public拉完了，自动拉一页private
                    if let cursor = result.cursor, cursor.count > 0 {
                        self.tableView.reloadData()
                        self.tableView.mj_header?.endRefreshing()
                        self.tableView.mj_footer?.endRefreshing()
                    } else {
                        self.loadChannlsData(refresh: false)
                    }
                }
            }
        } else {
            EMClient.shared().circleManager?.fetchVisibelPrivateChannels(inServer: self.serverId, limit: 20, cursor: self.privateResult?.cursor) { [weak self] result, error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let result = result {
                    if let privateResult = self.privateResult {
                        privateResult.append(result)
                    } else {
                        self.privateResult = result
                    }
                    self.tableView.reloadData()
                    self.tableView.mj_header?.endRefreshing()
                    if result.cursor?.count ?? 0 <= 0 {
                        self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                        self.tableView.mj_footer?.isHidden = true
                    } else {
                        self.tableView.mj_footer?.endRefreshing()
                    }
                }
            }
        }
    }
    
    private func removeChannel(channelId: String) {
        var indexPath: IndexPath?
        for i in 0..<(self.publicResult?.list?.count ?? 0) where self.publicResult?.list?[i].channelId == channelId {
            indexPath = IndexPath(row: i, section: 0)
            self.publicResult?.list?.remove(at: i)
            break
        }
        if indexPath == nil {
            for i in 0..<(self.privateResult?.list?.count ?? 0) where self.privateResult?.list?[i].channelId == channelId {
                indexPath = IndexPath(row: i + (self.publicResult?.list?.count ?? 0), section: 0)
                self.privateResult?.list?.remove(at: i)
                break
            }
        }
        if let indexPath = indexPath {
            self.tableView.performBatchUpdates {
                self.tableView.deleteRows(at: [indexPath], with: .none)
            }
        }
    }
    
    private func channel(channelId: String, isPublic: Bool? = nil) -> EMCircleChannel? {
        if isPublic != false {
            if let publicList = self.publicResult?.list {
                for i in publicList where i.channelId == channelId {
                    return i
                }
            }
            if isPublic == true {
                return nil
            }
        }
        if let privateList = self.privateResult?.list {
            for i in privateList where i.channelId == channelId {
                return i
            }
        }
        return nil
    }

    private func channel(index: Int) -> EMCircleChannel? {
        if index < self.publicResult?.list?.count ?? 0 {
            return self.publicResult?.list?[index] as? EMCircleChannel
        } else if index < (self.publicResult?.list?.count ?? 0) + (self.privateResult?.list?.count ?? 0) {
            return self.privateResult?.list?[index - (self.publicResult?.list?.count ?? 0)] as? EMCircleChannel
        }
        return nil
    }
    
    private func index(channelId: String) -> Int? {
        if let publicList = self.publicResult?.list {
            for i in 0..<publicList.count where publicList[i].channelId == channelId {
                return i
            }
        }
        if let privateList = privateResult?.list {
            for i in 0..<privateList.count where privateList[i].channelId == channelId {
                return i + (self.publicResult?.list?.count ?? 0)
            }
        }
        return nil
    }
    
    private func addThread(_ thread: EMChatThread) {
        if let channelId = thread.parentId, let item = self.threadMap[channelId], let item = item {
            var newList = item.0
            newList.insert(thread, at: 0)
            self.threadMap[channelId] = (newList, item.1)
            if let index = self.index(channelId: channelId) {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    private func addChannel(_ channel: EMCircleChannel) {
        if channel.type == .public {
            guard let result = self.publicResult else {
                return
            }
            if let cursor = result.cursor, cursor.count > 0 {
                return
            }
            var newList: [EMCircleChannel] = []
            if let oldList = result.list {
                newList.append(contentsOf: oldList)
            }
            newList.append(channel)
            result.list = newList
        } else if channel.type == .private {
            guard let result = self.privateResult else {
                return
            }
            if let cursor = result.cursor, cursor.count > 0 {
                return
            }
            var newList: [EMCircleChannel] = []
            if let oldList = result.list {
                newList.append(contentsOf: oldList)
            }
            newList.append(channel)
            result.list = newList
        }
        
        if let index = self.index(channelId: channel.channelId) {
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    private func updateThreadName(threadId: String, name: String) {
        var channelId: String?
        for (key, value) in self.threadMap {
            if channelId != nil {
                break
            }
            if let value = value {
                for thread in value.0 where thread.threadId == threadId {
                    thread.threadName = name
                    channelId = key
                    break
                }
            }
        }
        if let channelId = channelId, let index = self.index(channelId: channelId) {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    private func removeThread(threadId: String) {
        var channelId: String?
        for (key, value) in self.threadMap {
            if channelId != nil {
                break
            }
            if var list = value?.0 {
                for i in 0..<list.count where list[i].threadId == threadId {
                    list.remove(at: i)
                    self.threadMap[key] = (list, value?.1)
                    channelId = key
                    break
                }
            }
        }
        if let channelId = channelId, let index = self.index(channelId: channelId) {
            self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
        }
    }
    
    @objc private func didUpdateServerNotification(_ notification: Notification) {
        if let server = notification.object as? EMCircleServer, server.serverId == self.serverId {
            self.nameLabel.text = server.name
            self.tagListView.setTags(server.tags, itemHeight: self.tagListView.bounds.size.height)
            self.descLabel.text = server.desc
        }
    }
    
    @objc private func didCreateChannelNotification(_ notification: Notification) {
        if let channel = notification.object as? EMCircleChannel {
            self.addChannel(channel)
        }
    }
    
    @objc private func didDestroyChannelNotification(_ notification: Notification) {
        if let data = notification.object as? (String, String) {
            if data.0 == self.serverId {
                self.removeChannel(channelId: data.1)
            }
        }
    }
    
    @objc private func didUpdateChannelNotification(_ notification: Notification) {
        guard let channel = notification.object as? EMCircleChannel else {
            return
        }
        self.updateChannel(channel)
    }
    
    @objc private func didJoinChannelNotification(_ notification: Notification) {
        guard let channel = notification.object as? EMCircleChannel else {
            return
        }
        if channel.type == .private {
            self.addChannel(channel)
        }
    }
    
    @objc private func didDestroyThreadNotification(_ notification: Notification) {
        if let threadId = notification.object as? String {
            self.removeThread(threadId: threadId)
        }
    }
    
    private func updateChannel(_ channel: EMCircleChannel) {
        if channel.serverId != self.serverId {
            return
        }
        if let publicList = self.publicResult?.list {
            for i in 0..<publicList.count where publicList[i].channelId == channel.channelId {
                self.publicResult?.list![i] = channel
                self.tableView.performBatchUpdates {
                    self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
                }
                return
            }
        }
        if let privateList = self.privateResult?.list {
            for i in 0..<privateList.count where privateList[i].channelId == channel.channelId {
                self.privateResult?.list![i] = channel
                self.tableView.performBatchUpdates {
                    self.tableView.reloadRows(at: [IndexPath(row: i + (self.publicResult?.list?.count ?? 0), section: 0)], with: .none)
                }
                return
            }
        }
    }
    
    deinit {
        EMClient.shared().circleManager?.remove(channelDelegate: self)
        EMClient.shared().remove(self)
        EMClient.shared().chatManager?.remove(self)
        EMClient.shared().threadManager?.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
}

extension MessageServerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
        if let view = view as? MessageServerChannelHeader {
            view.createHandle = { [unowned self] in
                let vc = ChannelCreateViewController(showType: .create(serverId: self.serverId))
                self.presentNavigationController(rootViewController: vc)
            }
            view.foldHandle = { [unowned self] in
                self.channelFold = !self.channelFold
                self.tableView.performBatchUpdates {
                    self.tableView.reloadSections([0], with: .none)
                }
                self.tableView.mj_footer?.isHidden = self.channelFold
            }
            view.isFold = self.channelFold
            view.createEnable = self.server?.owner == EMClient.shared().currentUsername
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.channelFold {
            return 0
        } else {
            return (self.publicResult?.list?.count ?? 0) + (self.privateResult?.list?.count ?? 0)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? MessageServerChannelCell {
            let item = self.channel(index: indexPath.row)
            if let item = item {
                cell.channel = item
                if self.unfoldSet.contains(item.channelId) {
                    cell.isFold = false
                    if let value = self.threadMap[item.channelId], let threadTuple = value {
                        cell.setThreads(threads: threadTuple.0, hasNoMoreData: threadTuple.1 == nil)
                    }
                } else {
                    cell.isFold = true
                }
            }
            cell.channelClickHandle = { [unowned self] channel in
                self.channelClickAction(channel: channel, indexPath: indexPath)
            }
            cell.foldClickHandle = { [unowned self, unowned cell] channel in
                self.foldClickAction(channel: channel, cell: cell, indexPath: indexPath)
            }
            cell.threadClickHandle = { [unowned self] thread in
                self.threadClickAction(thread: thread, channel: item)
            }
            cell.moreClickHandle = { [unowned self] channel in
                self.moreClickAction(channel: channel, indexPath: indexPath)
            }
        }
        return cell
    }

    private func channelClickAction(channel: EMCircleChannel, indexPath: IndexPath) {
        EMClient.shared().circleManager?.checkSelfIsInChannel(serverId: channel.serverId, channelId: channel.channelId) { isJoined, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else if isJoined {
                if let conversation = EMClient.shared.chatManager?.getConversation(channel.channelId, type: .groupChat, createIfNotExist: true, isThread: false, isChannel: true) {
                    conversation.markAllMessages(asRead: nil)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                let vc = ChatViewController(chatType: .channel(serverId: channel.serverId, channelId: channel.channelId))
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = ServerJoinAlertViewController(showType: .joinChannel(serverId: channel.serverId, channelId: channel.channelId, joinHandle: { channel in
                    let chatVc = ChatViewController(chatType: .channel(serverId: channel.serverId, channelId: channel.channelId))
                    self.navigationController?.pushViewController(chatVc, animated: true)
                }))
                self.present(vc, animated: true)
            }
        }
    }

    private func foldClickAction(channel: EMCircleChannel, cell: MessageServerChannelCell, indexPath: IndexPath) {
        EMClient.shared().circleManager?.checkSelfIsInChannel(serverId: channel.serverId, channelId: channel.channelId) { isJoined, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else if isJoined {
                if self.unfoldSet.contains(channel.channelId) {
                    self.unfoldSet.remove(channel.channelId)
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                    cell.isFold = true
                    return
                }
                self.unfoldSet.insert(channel.channelId)
                cell.isFold = false
                if self.threadMap[channel.channelId] != nil {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                } else {
                    HUD.show(.progress, onView: self.view)
                    EMClient.shared().threadManager?.getChatThreadsFromServer(withParentId: channel.channelId, cursor: nil, pageSize: 20) { result, error in
                        HUD.hide()
                        if let error = error {
                            Toast.show(error.errorDescription, duration: 2)
                            return
                        }
                        if let result = result, let list = result.list {
                            let item = (list, list.count < 20 ? nil : result.cursor)
                            self.threadMap[channel.channelId] = item
                            self.tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            } else {
                let vc = ServerJoinAlertViewController(showType: .joinChannel(serverId: channel.serverId, channelId: channel.channelId, joinHandle: { channel in
                    let chatVc = ChatViewController(chatType: .channel(serverId: channel.serverId, channelId: channel.channelId))
                    self.navigationController?.pushViewController(chatVc, animated: true)
                }))
                self.present(vc, animated: true)
            }
        }
    }
    
    private func threadClickAction(thread: EMChatThread, channel: EMCircleChannel?) {
        let threadId: String? = thread.threadId
        if let threadId = threadId {
            EMClient.shared().threadManager?.joinChatThread(threadId) { [weak self] thread, error in
                guard let self = self else {
                    return
                }
                if let error = error, error.code != .userAlreadyExist {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    if let channel = channel {
                        let vc = ChatViewController(chatType: .thread(threadId: ChannelThreadId(serverId: self.serverId, channelId: channel.channelId, threadId: threadId)))
                        vc.subtitle = "# \(channel.name)"
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
    
    private func moreClickAction(channel: EMCircleChannel, indexPath: IndexPath) {
        if self.unfoldSet.contains(channel.channelId), let opt = self.threadMap[channel.channelId], let opt = opt {
            HUD.show(.progress, onView: self.view)
            EMClient.shared().threadManager?.getChatThreadsFromServer(withParentId: channel.channelId, cursor: opt.1, pageSize: 20) { result, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                    return
                }
                if let result = result, let list = result.list {
                    var old = opt.0
                    old.append(contentsOf: list)
                    let item = (old, list.count < 20 ? nil : result.cursor)
                    self.threadMap[channel.channelId] = item
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
}

extension MessageServerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let channelId = self.channel(index: indexPath.row)?.channelId
        if let channelId = channelId, self.unfoldSet.contains(channelId), let opt = self.threadMap[channelId] {
            if let opt = opt {
                if let cursor = opt.1, cursor.count > 0 {
                    return CGFloat(76 + 40 + opt.0.count * 40)
                } else {
                    return CGFloat(76 + opt.0.count * 40)
                }
            }
        }
        return 76
    }
}

extension MessageServerViewController: EMCircleManagerServerDelegate {
    func onServerUpdated(_ event: EMCircleServerEvent) {
        if event.serverId == self.serverId {
            self.nameLabel.text = event.serverName
            self.descLabel.text = event.serverDesc
        }
    }
}

extension MessageServerViewController: EMCircleManagerChannelDelegate {
    func onChannelCreated(_ serverId: String, channelId: String, creator: String) {
        EMClient.shared().circleManager?.fetchChannelDetail(serverId, channelId: channelId) { channel, _ in
            if let channel = channel, channel.serverId == self.serverId {
                self.addChannel(channel)
            }
        }
    }
    func onChannelDestroyed(_ serverId: String, channelId: String, initiator: String) {
        if serverId != self.serverId {
            return
        }
        self.removeChannel(channelId: channelId)
    }
    func onChannelUpdated(_ serverId: String, channelId: String, name: String, desc: String, initiator: String) {
        if serverId != self.serverId {
            return
        }
        if let channel = self.channel(channelId: channelId) {
            channel.name = name
            channel.desc = desc
            if let index = self.index(channelId: channelId) {
                self.tableView.performBatchUpdates {
                    self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                }
            }
        }
    }
    
    func onMemberRemoved(fromChannel serverId: String, channelId: String, member: String, initiator: String) {
        if serverId == self.serverId, member == EMClient.shared().currentUsername, let channel = self.channel(channelId: channelId), channel.type == .private {
            ServerRoleManager.shared.queryServerRole(serverId: channel.serverId) { role in
                if channel.serverId == self.serverId && role == .user {
                    self.removeChannel(channelId: channelId)
                }
            }
        }
    }
}

extension MessageServerViewController: EMChatManagerDelegate {
    func conversationListDidUpdate(_ aConversationList: [EMConversation]) {
        self.tableView.reloadData()
    }
    
    func onConversationRead(_ from: String, to: String) {
        self.tableView.reloadData()
    }
    
    func messagesDidReceive(_ aMessages: [EMChatMessage]) {
        self.tableView.reloadData()
    }
}

extension MessageServerViewController: EMThreadManagerDelegate {
    func onChatThreadCreate(_ event: EMChatThreadEvent) {
        if let thread = event.chatThread {
            self.addThread(thread)
        }
    }
    
    func onChatThreadUpdate(_ event: EMChatThreadEvent) {
        if event.type == .update, let threadId = event.chatThread.threadId, let name = event.chatThread.threadName {
            self.updateThreadName(threadId: threadId, name: name)
        }
    }
    
    func onChatThreadDestroy(_ event: EMChatThreadEvent) {
        if event.type == .delete, let threadId = event.chatThread.threadId {
            self.removeThread(threadId: threadId)
        }
    }
}

extension MessageServerViewController: EMMultiDevicesDelegate {
    func multiDevicesCircleServerEventDidReceive(_ aEvent: EMMultiDevicesEvent, serverId: String, ext aExt: Any?) {
        if serverId != self.serverId {
            return
        }
        switch aEvent {
        case .circleServerUpdate:
            self.updateServerDetail(refresh: true)
        default:
            break
        }
    }
    
    func multiDevicesCircleChannelEventDidReceive(_ aEvent: EMMultiDevicesEvent, channelId: String, ext aExt: Any?) {
        switch aEvent {
        case .circleChannelDestroy:
            self.removeChannel(channelId: channelId)
        case .circleChannelUpdate:
            if let channel = self.channel(channelId: channelId) {
                EMClient.shared().circleManager?.fetchChannelDetail(channel.serverId, channelId: channelId, completion: { channel, _ in
                    if let channel = channel {
                        self.updateChannel(channel)
                    }
                })
            }
        case .circleChannelCreate, .circleChannelJoin:
            EMClient.shared().circleManager?.fetchChannelDetail(self.serverId, channelId: channelId, completion: { channel, _ in
                if let channel = channel {
                    self.addChannel(channel)
                }
            })
        case .circleChannelExit:
            if let channel = self.channel(channelId: channelId), channel.type == .private {
                ServerRoleManager.shared.queryServerRole(serverId: channel.serverId) { role in
                    if channel.serverId == self.serverId && role == .user {
                        self.removeChannel(channelId: channelId)
                    }
                }
            }
        default:
            break
        }
    }
}
