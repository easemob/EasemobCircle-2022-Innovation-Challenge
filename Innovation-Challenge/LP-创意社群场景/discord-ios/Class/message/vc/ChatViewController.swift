//
//  ChatViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/1.
//

import UIKit
import HyphenateChat
import TZImagePickerController
import MJRefresh
import PKHUD
import Kingfisher
import AVKit

// swiftlint:disable type_body_length
// swiftlint:disable file_length

class ChatViewController: BaseViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var chatInputView: ChatInputView!
    @IBOutlet private weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    private let chatType: ChatType
    
    private var messageList: [EMChatMessage] = []
    
    private lazy var currentConversation: EMConversation? = {
        switch self.chatType {
        case .group, .single:
            return EMClient.shared().chatManager?.getConversationWithConvId(self.chatType.conversationId)
        case .thread:
            return EMClient.shared().chatManager?.getConversation(self.chatType.conversationId, type: .groupChat, createIfNotExist: true, isThread: true, isChannel: false)
        case .channel:
            return EMClient.shared().chatManager?.getConversation(self.chatType.conversationId, type: .groupChat, createIfNotExist: true, isThread: false, isChannel: true)
        }
    }()

    init(chatType: ChatType) {
        self.chatType = chatType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.updateTitle()
    
        let moreButton = UIButton()
        moreButton.setImage(UIImage(named: "more_white"), for: .normal)
        moreButton.addTarget(self, action: #selector(moreAction(_:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(MessageTextCell.self, forCellReuseIdentifier: "text")
        self.tableView.register(MessageImageCell.self, forCellReuseIdentifier: "image")
        self.tableView.register(MessageVideoCell.self, forCellReuseIdentifier: "video")
        self.tableView.register(MessageFileCell.self, forCellReuseIdentifier: "file")
        self.tableView.register(MessageCircleInviteCell.self, forCellReuseIdentifier: "circle_invite")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.setupChatInputViewHandle()
        self.addNotificationAndDelegate()
        self.loadMessage()
        
        switch self.chatType {
        case .thread:
            self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [unowned self] in
                self.loadMessage()
            })
            let threadHeadView = Bundle.main.loadNibNamed("ThreadMessageHeadView", owner: nil)?.first as? ThreadMessageHeadView
            threadHeadView?.threadId = self.chatType.conversationId
            threadHeadView?.didChangeHeight = { [unowned self, unowned threadHeadView] in
                threadHeadView?.removeFromSuperview()
                self.tableView.tableHeaderView = nil
                self.tableView.tableHeaderView = threadHeadView
                self.tableView.setNeedsLayout()
                self.tableView.layoutIfNeeded()
            }
            self.tableView.tableHeaderView = threadHeadView
            self.tableView.setNeedsLayout()
        default:
            self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [unowned self] in
                self.loadMessage()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let view = self.tableView.tableHeaderView {
            view.removeFromSuperview()
            self.tableView.tableHeaderView = nil
            self.tableView.tableHeaderView = view
            self.tableView.setNeedsLayout()
            self.tableView.layoutIfNeeded()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.chatInputView.reset()
    }
    
    private func loadMessage() {
        switch self.chatType {
        case .group(groupId: let groupId):
            self.loadMessageFromCache(conversationId: groupId)
        case .single(userId: let userId):
            self.loadMessageFromCache(conversationId: userId)
        case .thread(threadId: let threadId):
            self.loadMessageFromServer(conversationId: threadId.threadId, direction: .down, isThread: true, isChannel: false)
        case .channel(serverId: _, channelId: let channelId):
            self.loadMessageFromServer(conversationId: channelId, direction: .up, isThread: false, isChannel: true)
        }
    }
    
    private func setupChatInputViewHandle() {
        self.chatInputView.sendHandle = { [unowned self] _ in
            self.sendAction()
            self.chatInputView.replyCloseAction()
        }
        
        self.chatInputView.didSelectedMoreItemHandle = { [unowned self] item in
            switch item {
            case .videoLibrary:
                PHPhotoLibrary.request {
                    if let vc = TZImagePickerController(maxImagesCount: 1, delegate: nil) {
                        vc.allowPickingOriginalPhoto = false
                        vc.allowPickingOriginalPhoto = false
                        vc.videoMaximumDuration = 600
                        vc.allowPickingVideo = true
                        vc.allowPickingImage = false
                        vc.didFinishPickingVideoHandle = { [weak self] _, asset in
                            guard let self = self else {
                                return
                            }
                            
                            guard let ass = asset else {
                                return
                            }
                            
                            HUD.show(.progress, onView: self.view)
                            
                            let ops = PHVideoRequestOptions()
                            ops.version = .current
                            ops.deliveryMode = .fastFormat
                            ops.isNetworkAccessAllowed = true
                            PHImageManager.default().requestAVAsset(forVideo: ass, options: ops) { avAsset, _, _ in
                                
                                guard let _ = avAsset else {
                                    DispatchQueue.main.async {
                                        HUD.hide()
                                        HUD.show(.label("视频读取异常"))
                                    }
                                    return
                                }
                                
                                let urlAsset = avAsset as! AVURLAsset
                                let url = urlAsset.url
                             
                                let body = EMVideoMessageBody(localPath: url.absoluteString, displayName: "video")
                                body.duration = Int32(ass.duration)
                                
                                DispatchQueue.main.async {
                                    HUD.hide()
                                    self.sendMessage(body: body)
                                }
                            }
                            
                        }
                        self.present(vc, animated: true)
                    }
                }
                
                
            case .photoLibrary:
                PHPhotoLibrary.request {
                    if let vc = TZImagePickerController(maxImagesCount: 1, delegate: nil) {
                        vc.allowPickingOriginalPhoto = false
                        vc.didFinishPickingPhotosHandle = { [weak self] images, _, _ in
                            guard let self = self else {
                                return
                            }
                            guard let image = images?.first, let data = image.jpegData(compressionQuality: 1) else {
                                return
                            }
                            let body = EMImageMessageBody(data: data, displayName: "image")
                            body.size = image.size
                            self.sendMessage(body: body)
                        }
                        self.present(vc, animated: true)
                    }
                }
            case .camera:
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.delegate = self
                self.present(vc, animated: true)
            case .file:
                if #available(iOS 14.0, *) {
                    let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.content, .text, .sourceCode, .image, .jpeg, .png, .pdf, .mp3])
                    vc.delegate = self
                    self.present(vc, animated: true)
                } else {
                    let vc = UIDocumentPickerViewController(documentTypes: ["public.content", "public.text", "public.source-code", "public.image", "public.jpeg", "public.png", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt"], in: .open)
                    vc.delegate = self
                    self.present(vc, animated: true)
                }
            }
        }
        
        self.chatInputView.showTypeChangeHandle = { [unowned self] in
            let row = self.messageList.count - 1
            if row >= 0 {
                self.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    private func addNotificationAndDelegate() {
        EMClient.shared().chatManager?.add(self, delegateQueue: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserInfoUpdateNotification(_:)), name: EMCurrentUserInfoUpdate, object: nil)
        switch self.chatType {
        case .single(userId: _):
            NotificationCenter.default.addObserver(self, selector: #selector(userInfoUpdateNotification(_:)), name: EMUserInfoUpdate, object: nil)
        case .channel(serverId: _, channelId: _):
            NotificationCenter.default.addObserver(self, selector: #selector(didUpdateChannelNotification(_:)), name: EMCircleDidUpdateChannel, object: nil)
            EMClient.shared().circleManager?.add(serverDelegate: self, queue: nil)
            EMClient.shared().circleManager?.add(channelDelegate: self, queue: nil)
            EMClient.shared().threadManager?.add(self, delegateQueue: nil)
        case .thread(threadId: _):
            EMClient.shared().threadManager?.add(self, delegateQueue: nil)
        default:
            break
        }
    }
    
    private func loadMessageFromCache(conversationId: String) {
        guard let conversation = EMClient.shared().chatManager?.getConversationWithConvId(conversationId) else {
            return
        }
        conversation.loadMessagesStart(fromId: self.messageList.first?.messageId, count: 20, searchDirection: .up) { [weak self] messages, error in
            guard let self = self else {
                return
            }
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else if let messages = messages {
                self.messageList.append(contentsOf: messages)
                self.tableView.reloadData()
                if !(self.tableView.mj_header?.isRefreshing ?? false) && self.messageList.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messageList.count - 1, section: 0), at: .bottom, animated: false)
                }
                if messages.count < 20 {
                    self.tableView.mj_header?.endRefreshing()
                    self.tableView.mj_header?.isHidden = true
                } else {
                    self.tableView.mj_header?.endRefreshing()
                }
            }
        }
    }
    
    private func loadMessageFromServer(conversationId: String, direction: EMMessageFetchHistoryDirection, isThread: Bool, isChannel: Bool) {
        let startMessage = direction == .up ? self.messageList.first : self.messageList.last
        EMClient.shared().chatManager?.asyncFetchHistoryMessages(fromServer: conversationId, conversationType: .groupChat, startMessageId: startMessage?.messageId, fetch: direction, pageSize: 20) { [weak self] _, _ in
            guard let self = self else {
                return
            }
            guard let conversation = EMClient.shared().chatManager?.getConversation(self.chatType.conversationId, type: .groupChat, createIfNotExist: true, isThread: isThread, isChannel: isChannel) else {
                return
            }
            conversation.loadMessagesStart(fromId: startMessage?.messageId, count: 20, searchDirection: direction == .up ? .up : .down) { [weak self] messages, _ in
                guard let self = self else {
                    return
                }
                guard let messages = messages else {
                    return
                }
                if direction == .up {
                    self.messageList.insert(contentsOf: messages, at: 0)
                } else {
                    self.messageList.append(contentsOf: messages)
                }
                self.tableView.reloadData()
                if direction == .up && !(self.tableView.mj_header?.isRefreshing ?? false) && self.messageList.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.messageList.count - 1, section: 0), at: .bottom, animated: false)
                }
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
                if messages.count < 20 {
                    self.tableView.mj_header?.isHidden = true
                    self.tableView.mj_footer?.isHidden = true
                }
            }
        }
    }
    
    private func updateTitle() {
        switch self.chatType {
        case .single(userId: let userId):
            if let userInfo = UserInfoManager.share.userInfo(userId: userId) {
                self.title = userInfo.showname
            } else {
                self.title = userId
            }
        case .channel(serverId: let serverId, channelId: let channelId):
            self.title = channelId
            EMClient.shared().circleManager?.fetchChannelDetail(serverId, channelId: channelId) { channel, _ in
                if let channel = channel {
                    self.title = channel.name
                    if let desc = channel.desc, desc.count > 0 {
                        self.subtitle = desc
                    }
                    self.titleLeftImageName = channel.type == .public ? "#_channel_public" : "#_channel_private"
                }
            }
        case .group(groupId: let groupId):
            self.title = groupId
        case .thread(threadId: let threadId):
            self.title = threadId.threadId
            EMClient.shared().threadManager?.getChatThread(fromSever: threadId.threadId) { thread, _ in
                if let threadName = thread?.threadName {
                    self.title = threadName
                }
            }
        }
    }
    
    private func sendAction() {
        guard let text = self.chatInputView.text, text.count > 0 else {
            return
        }
        let messageBody = EMTextMessageBody(text: text)
        self.sendMessage(body: messageBody)
    }
    
    private func sendMessage(body: EMMessageBody) {
        guard let message = EMClient.shared().chatManager?.createSendMessage(body: body, chatType: self.chatType) else {
            return
        }
        EMClient.shared().chatManager?.send(message, progress: nil) { _, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            }
        }
        
        self.messageList.append(message)
        let indexPath = IndexPath(row: self.messageList.count - 1, section: 0)
        self.tableView.performBatchUpdates({
            self.tableView.insertRows(at: [indexPath], with: .fade)
        }, completion: { _ in
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        })
    }
    
    @objc private func moreAction(_ sender: UIButton) {
        self.chatInputView.reset()
        switch self.chatType {
        case .single(userId: let userId):
            let v = BubbleMenuView(baseView: sender)
            v.addMenuItem(image: UIImage(named: "server_delete")!, title: "删除会话") {
                let vc = UIAlertController(title: "删除会话", message: "确认删除后，将清空聊天记录。", preferredStyle: .alert)
                vc.addAction(UIAlertAction(title: "取消", style: .default))
                vc.addAction(UIAlertAction(title: "确定", style: .destructive, handler: { _ in
                    EMClient.shared().chatManager?.deleteConversation(userId, isDeleteMessages: true)
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(vc, animated: true)
            }
            v.show()
        case .group(groupId: _):
            break
        case .channel(serverId: let serverId, channelId: let channelId):
            let vc = ChannelSettingViewController(serverId: serverId, channelId: channelId)
            vc.didDeleteHandle = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            self.presentNavigationController(rootViewController: vc)
        case .thread(threadId: let threadId):
            let vc = ThreadSettingViewController(threadId: threadId)
            vc.didDeleteHandle = { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            self.presentNavigationController(rootViewController: vc)
        }
    }
    
    @IBAction func tableViewTapAction(_ sender: UITapGestureRecognizer) {
        self.chatInputView.resignFirstResponder()
        self.inputViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func currentUserInfoUpdateNotification(_ notification: Notification) {
        if let visibleRows = self.tableView.indexPathsForVisibleRows {
            self.tableView.performBatchUpdates {
                self.tableView.reloadRows(at: visibleRows, with: .none)
            }
        }
    }
    
    @objc private func userInfoUpdateNotification(_ notification: Notification) {
        switch self.chatType {
        case .single(userId: let userId):
            if let userInfo = notification.object as? EMUserInfo, userInfo.userId == userId {
                self.title = userInfo.showname
            }
        default:
            break
        }
    }
    
    @objc private func didUpdateChannelNotification(_ notification: Notification) {
        switch self.chatType {
        case .channel(serverId: _, channelId: let channelId):
            if let channel = notification.object as? EMCircleChannel, channel.channelId == channelId {
                self.title = channel.name
            }
        default:
            break
        }
    }
    
    deinit {
        EMClient.shared().chatManager?.remove(self)
        EMClient.shared().circleManager?.remove(serverDelegate: self)
        EMClient.shared().circleManager?.remove(channelDelegate: self)
        EMClient.shared().threadManager?.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.messageList[indexPath.row]
        let cell = self.dequeueReusableCell(message: message, indexPath: indexPath)
        cell?.message = message
        if let cell = cell {
            self.addCellCommonAction(cell: cell, indexPath: indexPath)
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }
    
    private func dequeueReusableCell(message: EMChatMessage, indexPath: IndexPath) -> MessageBaseCell? {
        if message.body.type == .text || message.body.type == .custom {
            if let textCell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as? MessageTextCell {
                return textCell
            }
        } else if message.body.type == .image {
            if let imageCell = self.dequeueImageReusableCell(message: message, indexPath: indexPath) {
                return imageCell
            }
        }
        else if message.body.type == .video {
            if let imageCell = self.dequeueVideoReusableCell(message: message, indexPath: indexPath) {
                return imageCell
            }
        }
        else if message.body.type == .file {
            if let fileCell = tableView.dequeueReusableCell(withIdentifier: "file", for: indexPath) as? MessageFileCell {
                fileCell.didClickHandle = { [unowned self] message in
                    if let fileBody = message?.body as? EMFileMessageBody, let title = fileBody.displayName, let url = URL(string: fileBody.remotePath) {
                        let items: [Any] = [title, url]
                        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
                        self.present(vc, animated: true)
                    }
                }
                return fileCell
            }
        } else if let circleCell = self.dequeueCircleReusableCell(message: message, indexPath: indexPath) {
            return circleCell
        }
        return nil
    }
    
    private func dequeueImageReusableCell(message: EMChatMessage, indexPath: IndexPath) -> MessageBaseCell? {
        if let imageCell = tableView.dequeueReusableCell(withIdentifier: "image", for: indexPath) as? MessageImageCell {
            imageCell.didClickHandle = { [unowned self] image in
                self.chatInputView.resignFirstResponder()
                BigImageView.show { imageView in
                    guard let imageBody = message.body as? EMImageMessageBody else {
                        imageView.image = nil
                        return
                    }
                    if let localPath = imageBody.localPath, localPath.count > 0, let image = UIImage(contentsOfFile: localPath) {
                        imageView.image = image
                    } else if let remotePath = imageBody.remotePath, let url = URL(string: remotePath) {
                        HUD.show(.progress, onView: imageView)
                        imageView.kf.setImage(with: url, placeholder: image, options: nil) { _ in
                            HUD.hide()
                        }
                    }
                }
            }
            return imageCell
        }
        return nil
    }
    
    private func dequeueVideoReusableCell(message: EMChatMessage, indexPath: IndexPath) -> MessageBaseCell? {
        if let videoCell = tableView.dequeueReusableCell(withIdentifier: "video", for: indexPath) as? MessageVideoCell {
            videoCell.didClickHandle = { [unowned self] _ in
                self.chatInputView.resignFirstResponder()
               
                if let body = message.body as? EMVideoMessageBody {
                    let playerVC = AVPlayerViewController()
                    let localPath = body.localPath
                   
                    guard let path = localPath else {
                        return
                    }
                    
                    let playUrl = URL(fileURLWithPath: path)
                    
                    let player = AVPlayer(url: playUrl)
                    playerVC.player = player
                    
                    self.present(playerVC, animated: true)
                    player.play()
                }
            }
            return videoCell
        }
        return nil
    }
    
    private func dequeueCircleReusableCell(message: EMChatMessage, indexPath: IndexPath) -> MessageBaseCell? {
        guard message.body.type == .custom, let body = message.body as? EMCustomMessageBody, let event = body.event else {
            return nil
        }
        if event == "invite_server" || event == "invite_channel" {
            if let circleInviteCell = tableView.dequeueReusableCell(withIdentifier: "circle_invite", for: indexPath) as? MessageCircleInviteCell {
                circleInviteCell.clickHandle = { [unowned self] in
                    self.chatInputView.resignFirstResponder()
                    if message.from == EMClient.shared().currentUsername {
                        return
                    }
                    if event == "invite_server", let serverId = body.customExt["server_id"] {
                        EMClient.shared().circleManager?.checkSelfIs(inServer: serverId, completion: { isIn, _ in
                            if isIn {
                                self.navigationController?.popToRootViewController(animated: true)
                                self.gotoHomePage(serverId: serverId)
                            } else {
                                let vc = ServerJoinAlertViewController(showType: .inviteServer(serverId: serverId, inviter: message.from, joinHandle: { server in
                                    let chatVc = ChatViewController(chatType: .channel(serverId: server.serverId, channelId: server.defaultChannelId))
                                    self.navigationController?.pushViewController(chatVc, animated: true)
                                }))
                                self.present(vc, animated: true)
                            }
                        })
                    } else if let serverId = body.customExt["server_id"], let channelId = body.customExt["channel_id"], let icon = body.customExt["icon"], let serverName = body.customExt["server_name"], let channelName = body.customExt["channel_name"], let desc = body.customExt["desc"] {
                        EMClient.shared().circleManager?.checkSelfIsInChannel(serverId: serverId, channelId: channelId, completion: { isIn, _ in
                            if isIn {
                                self.navigationController?.popToRootViewController(animated: true)
                                self.gotoHomePage(serverId: serverId)
                            } else {
                                let channelInvite = EMCircleChannelExt()
                                channelInvite.serverId = serverId
                                channelInvite.channelId = channelId
                                channelInvite.serverIcon = icon
                                channelInvite.serverName = serverName
                                channelInvite.channelName = channelName
                                channelInvite.channelDesc = desc
                                let vc = ServerJoinAlertViewController(showType: .inviteChannel(inviteInfo: channelInvite, inviter: message.from, joinHandle: { channel in
                                    let chatVc = ChatViewController(chatType: .channel(serverId: channel.serverId, channelId: channel.channelId))
                                    self.navigationController?.pushViewController(chatVc, animated: true)
                                }))
                                self.present(vc, animated: true)
                            }
                        })
                    }
                }
                return circleInviteCell
            }
        } else if event == "join_server" || event == "join_channel" {
            if let textCell = tableView.dequeueReusableCell(withIdentifier: "text", for: indexPath) as? MessageTextCell {
                return textCell
            }
        }
        return nil
    }
    
    private func addCellCommonAction(cell: MessageBaseCell, indexPath: IndexPath) {
        cell.didLongPressHandle = { [unowned self] message in
            self.chatInputView.resignFirstResponder()
            if message.body.type == .text, let ext = message.ext as? [String: Any], let isRecall = ext["recall"] as? Bool, isRecall {
                return
            }
//            if message.body.type == .custom {
//                return
//            }
            let menuItem = self.messageLongPressMenuItems(message: message)
            ChatBottomMenuView.show(menuItems: menuItem, delegate: self, userInfo: [
                "index": indexPath.row,
                "message": message
            ])
        }
        cell.didSelectedReaction = { [unowned self] message, reaction in
            self.chatInputView.resignFirstResponder()
            guard let reactionStr = reaction.reaction else {
                return
            }
            if reaction.isAddedBySelf {
                self.removeReaction(messageId: message.messageId, readtion: reactionStr)
            } else {
                self.addReaction(messageId: message.messageId, reaction: reactionStr)
            }
        }
        cell.didClickAddReaction = { [unowned self] message in
            self.chatInputView.resignFirstResponder()
            if message.body.type == .text, let ext = message.ext as? [String: Any], let isRecall = ext["recall"] as? Bool, isRecall {
                return
            }
            let menuItem = self.messageLongPressMenuItems(message: message)
            ChatBottomMenuView.show(menuItems: menuItem, delegate: self, userInfo: [
                "index": indexPath.row,
                "message": message
            ])
        }
        cell.didClickHeadHandle = { [unowned self] message in
            self.chatInputView.resignFirstResponder()
            if message.from == EMClient.shared().currentUsername {
                let vc = UserInfoViewController(showType: .me)
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = UserInfoViewController(showType: .other(userId: message.from))
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        cell.didClickThreadHandle = { [unowned self] message in
            self.chatInputView.resignFirstResponder()
            if message.chatThread?.threadId != nil {
                self.didClickThreadItem(message: message)
            }
        }
    }
    
    private func messageLongPressMenuItems(message: EMChatMessage) -> [ChatBottomMenuView.MenuItem] {
        var menuItems: [ChatBottomMenuView.MenuItem] = []
        if message.body.type == .text || message.body.type == .custom {
            menuItems.append(.copy)
            menuItems.append(.reply)
            menuItems.append(.prankFunc)
        }
        
        switch self.chatType {
        case .channel(serverId: _, channelId: _), .group(groupId: _):
            switch message.body.type {
            case .text, .image, .file:
                menuItems.append(.thread)
            default:
                break
            }
        default:
            break
        }
        
        if message.from == EMClient.shared().currentUsername {
            menuItems.append(.recall)
        }
        
        return menuItems
    }
    
    private func reloadVisiableCell(messageIds: [String]) {
        guard let visiableIndexPaths = self.tableView.indexPathsForVisibleRows else {
            return
        }
        var reloadIndexpaths: [IndexPath] = []
        for indexPath in visiableIndexPaths where messageIds.contains(self.messageList[indexPath.row].messageId) {
            reloadIndexpaths.append(indexPath)
        }
        if reloadIndexpaths.count > 0 {
            self.tableView.performBatchUpdates {
                self.tableView.reloadRows(at: reloadIndexpaths, with: .none)
            }
        }
    }
    
    private func reloadCell(messageId: String) {
        for i in 0..<self.messageList.count where self.messageList[i].messageId == messageId {
            self.tableView.performBatchUpdates {
                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .none)
            }
            return
        }
    }
    
    private func addReaction(messageId: String, reaction: String) {
        EMClient.shared().chatManager?.addReaction(reaction, toMessage: messageId) { [weak self] error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                self?.reloadVisiableCell(messageIds: [messageId])
            }
        }
    }
    
    private func removeReaction(messageId: String, readtion: String) {
        EMClient.shared().chatManager?.removeReaction(readtion, fromMessage: messageId) { [weak self] error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                self?.reloadVisiableCell(messageIds: [messageId])
            }
        }
    }
    
    private func gotoHomePage(serverId: String) {
        if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController {
            tabBarController.selectedIndex = 0
        }
        NotificationCenter.default.post(name: MainShouldSelectedServer, object: serverId)
    }
}

extension ChatViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.chatInputView.resignFirstResponder()
    }
}

extension ChatViewController: EMChatManagerDelegate {
    func messagesDidReceive(_ aMessages: [EMChatMessage]) {
        var appendIndexs: [IndexPath] = []
        for message in aMessages where message.isBelongTo(chatType: self.chatType) {
            self.messageList.append(message)
            appendIndexs.append(IndexPath(row: self.messageList.count - 1, section: 0))
            
            //是否整蛊
            if (message.body.type == .custom) {
                if let textBody = message.body as? EMCustomMessageBody {
                    let event = textBody.event
                    if event == "PRANK"{
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PRANK-Notify"), object: textBody.customExt["ID"], userInfo: nil)
                    }
                }
            }
        }
        if appendIndexs.count > 0 {
            self.tableView.insertRows(at: appendIndexs, with: .fade)
            if let last = appendIndexs.last {
                self.tableView.scrollToRow(at: last, at: .bottom, animated: true)
            }
        }
        self.currentConversation?.markAllMessages(asRead: nil)
    }
    
    func messageReactionDidChange(_ changes: [EMMessageReactionChange]) {
        var refreshMessageId: [String] = []
        for change in changes {
            if let messageId = change.messageId {
                refreshMessageId.append(messageId)
            }
        }
        self.reloadVisiableCell(messageIds: refreshMessageId)
    }
    
    func messagesInfoDidRecall(_ aRecallMessagesInfo: [EMRecallMessageInfo]) {
        for info in aRecallMessagesInfo {
            self.didRecallMessage(messageId: info.recallMessage.messageId)
        }
    }
}

extension ChatViewController: ChatBottomMenuViewDelegate {
    func chatBottomMenuViewDidSelectedReaction(view: ChatBottomMenuView, reaction: String, userInfo: [String: Any]?) {
        guard let index = userInfo?["index"] as? Int else {
            return
        }
        let message = self.messageList[index]
        if let emoji = imageNameEmoji(emoji: reaction) {
            if message.getReaction(emoji)?.isAddedBySelf ?? false {
                self.removeReaction(messageId: message.messageId, readtion: emoji)
            } else {
                self.addReaction(messageId: message.messageId, reaction: emoji)
            }
        }
    }
    
    func chatBottomMenuViewDidSelectedMenuItem(view: ChatBottomMenuView, menuItem: ChatBottomMenuView.MenuItem, userInfo: [String: Any]?) {
        guard let index = userInfo?["index"] as? Int else {
            return
        }
        let message = self.messageList[index]
        switch menuItem {
        case .copy:
            if message.body.type == .text, let textBody = message.body as? EMTextMessageBody {
                UIPasteboard.general.string = textBody.text
                Toast.show("消息已复制", duration: 2)
            }
        case .recall:
            EMClient.shared().chatManager?.recallMessage(withMessageId: message.messageId) { error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    self.didRecallMessage(messageId: message.messageId)
                }
            }
        case .reply:
            if message.body.type == .text, let textBody = message.body as? EMTextMessageBody {
                var textStr = textBody.text
                textStr = textStr.components(separatedBy: "\n-------\r\n").first ?? textStr
                self.chatInputView.updateReply("回复("+message.from+"): "+textStr)
                self.chatInputView.becomeFirstResponder()
                
                let userId = message.from
                UserInfoManager.share.queryUserInfo(userId: userId, loadCache: false) { userInfo, _ in
                    if let name = userInfo?.showname {
                        self.chatInputView.updateReply("回复("+name+"): "+textStr)
                    }
                }
                
            } else {
                Toast.show("暂不支持", duration: 2)
            }
        case .prankFunc:
            let userId = message.from
            UserInfoManager.share.queryUserInfo(userId: userId, loadCache: false) { userInfo, _ in
                if let name = userInfo?.showname {
//                    let text = "向 {" + name + "} 投掷整蛊"
//                    let messageBody = EMTextMessageBody(text: text)
//                    self.sendMessage(body: messageBody)
                    
                    
                    let customBody = EMCustomMessageBody(event: "PRANK", customExt: ["ID" : userId,"NAME":name])
                    self.sendMessage(body: customBody)
                    
                    //主态
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PRANK-Notify"), object: userId, userInfo: nil)
                }
                
            }
            
           
            //整蛊
            break
        
        case .thread:
            self.didClickThreadItem(message: message)
        }
    }
    
    func chatBottomMenuViewGetIsAdded(view: ChatBottomMenuView, reaction: String, userInfo: [String: Any]?) -> Bool {
        if let message = userInfo?["message"] as? EMChatMessage, let imageName = imageNameEmoji(emoji: reaction) {
            return message.getReaction(imageName)?.isAddedBySelf ?? false
        }
        return false
    }
    
    private func didClickThreadItem(message: EMChatMessage) {
        if let thread = message.chatThread {
            if let threadId = thread.threadId {
                EMClient.shared().threadManager?.joinChatThread(threadId) { [weak self] thread, error in
                    guard let self = self else {
                        return
                    }
                    if let error = error, error.code != .userAlreadyExist {
                        Toast.show(error.errorDescription, duration: 2)
                    } else if let tid = self.chatType.createThreadId(threadId: threadId) {
                        let vc = ChatViewController(chatType: .thread(threadId: tid))
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        } else {
            let vc = ThreadCreateViewController(chatType: self.chatType, message: message)
            vc.threadCreatedHandle = { [unowned self] in
                self.reloadVisiableCell(messageIds: [message.messageId])
                if var vcs = self.navigationController?.viewControllers {
                    vcs.remove(at: vcs.count - 2)
                    self.navigationController?.viewControllers = vcs
                }
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func didRecallMessage(messageId: String) {
        guard let index = self.messageList.firstIndex(where: { msg in
            return msg.messageId == messageId
        }) else {
            return
        }
        guard let conversation = self.currentConversation else {
            return
        }
        let message = self.messageList[index]
        let body = EMTextMessageBody(text: "撤回了一条消息")
        if let newMessage = EMClient.shared().chatManager?.createSendMessage(body: body, chatType: self.chatType) {
            newMessage.ext = [
                "recall": true
            ]
            newMessage.from = message.from
            newMessage.messageId = message.messageId
            newMessage.localTime = message.localTime
            newMessage.timestamp = message.timestamp
            conversation.insert(newMessage, error: nil)
            self.messageList[index] = newMessage
            self.tableView.performBatchUpdates {
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
}

extension ChatViewController: EMThreadManagerDelegate {
    func onChatThreadUpdate(_ event: EMChatThreadEvent) {
        switch self.chatType {
        case .thread(threadId: let threadId):
            if threadId.threadId == event.chatThread.threadId {
                self.title = event.chatThread.threadName
            }
        case .channel(serverId: _, channelId: let channelId):
            if event.chatThread.parentId == channelId, let messageId = event.chatThread.messageId {
                self.reloadVisiableCell(messageIds: [messageId])
            }
        default:
            break
        }
    }
    func onChatThreadDestroy(_ event: EMChatThreadEvent) {
        switch self.chatType {
        case .thread(threadId: let threadId):
            if threadId.threadId == event.chatThread.threadId {
                self.navigationController?.popViewController(animated: true)
                Toast.show("子区已被销毁", duration: 2)
            }
        case .channel(serverId: _, channelId: let parentId), .group(groupId: let parentId):
            if event.chatThread.parentId == parentId {
                self.reloadCell(messageId: event.chatThread.messageId)
            }
        default:
            break
        }
    }
    func onUserKickOutOfChatThread(_ event: EMChatThreadEvent) {
        switch self.chatType {
        case .thread(threadId: let threadId):
            if threadId.threadId == event.chatThread.threadId {
                self.navigationController?.popViewController(animated: true)
                Toast.show("您已被从子区中移除", duration: 2)
            }
        default:
            break
        }
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let firstUrl = urls.first else {
            return
        }
        if !firstUrl.startAccessingSecurityScopedResource() {
            return
        }
        let fileCoordinator = NSFileCoordinator()
        fileCoordinator.coordinate(readingItemAt: firstUrl, error: nil) { url in
            if let data = try? Data(contentsOf: url) {
                let body = EMFileMessageBody(data: data, displayName: url.lastPathComponent)
                self.sendMessage(body: body)
                firstUrl.stopAccessingSecurityScopedResource()
            }
        }
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 1) {
            let body = EMImageMessageBody(data: imageData, displayName: nil)
            body.size = image.size
            self.sendMessage(body: body)
        }
        picker.dismiss(animated: true)
    }
}

extension ChatViewController: EMMultiDevicesDelegate {
    func multiDevicesChatThreadEventDidReceive(_ aEvent: EMMultiDevicesEvent, threadId aThreadId: String, ext aExt: Any?) {
        switch self.chatType {
        case .thread(threadId: let threadId):
            if threadId.threadId == aThreadId {
                if aEvent == .chatThreadLeave {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        default:
            break
        }
    }
}

extension ChatViewController: EMCircleManagerServerDelegate {
    func onServerDestroyed(_ serverId: String, initiator: String) {
        switch self.chatType {
        case .channel(serverId: let sId, channelId: _):
            if serverId == sId {
                self.navigationController?.popViewController(animated: true)
                Toast.show("社区已被销毁", duration: 2)
            }
        default:
            break
        }
    }
}

extension ChatViewController: EMCircleManagerChannelDelegate {
    func onChannelDestroyed(_ serverId: String, channelId: String, initiator: String) {
        switch self.chatType {
        case .channel(serverId: _, channelId: let cId):
            if channelId == cId {
                self.navigationController?.popViewController(animated: true)
                Toast.show("频道已被销毁", duration: 2)
            }
        default:
            break
        }
    }
    
    func onChannelUpdated(_ serverId: String, channelId: String, name: String, desc: String, initiator: String) {
        switch self.chatType {
        case .channel(serverId: _, channelId: let cId):
            if channelId == cId {
                self.title = name
                if desc.count > 0 {
                    self.subtitle = desc
                }
            }
        default:
            break
        }
    }
    
    func onMemberRemoved(fromChannel serverId: String, channelId: String, member: String, initiator: String) {
        switch self.chatType {
        case .channel(serverId: _, channelId: let cId):
            if channelId == cId, member == EMClient.shared().currentUsername {
                self.navigationController?.popViewController(animated: true)
                Toast.show("您已被从频道中移除", duration: 2)
            }
        default:
            break
        }
    }
}
