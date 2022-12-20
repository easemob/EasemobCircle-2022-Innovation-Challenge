//
//  ChatViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/24.
//

import UIKit
import HyphenateChat
import MessageKit
import InputBarAccessoryView

private let pageCount: Int32 = 20
private let outgoingAvatarOverlap: CGFloat = 17.5

class ChatViewController: MessagesViewController {
    
    static func newInstanceFromStoryboard(with server: EMCircleServer, channel: EMCircleChannel, thread: EMChatThread? = nil) -> ChatViewController {
        return newInstanceFromStoryboard(with: .circle(server, channel: channel, thread: thread))
    }
    
    static func newInstanceFromStoryboard(with userId: String) -> ChatViewController {
        return newInstanceFromStoryboard(with: .p2p(userId))
    }
    
    private static func newInstanceFromStoryboard(with type: Chat) -> ChatViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatViewController
        vc.chat =  type
        
        return vc
    }
    
    var chat: Chat! {
        didSet {
            conversation = chat.conversation
            
            Task {
                if let server = chat.server {
                    await UserInfoManager.shared.prefetchChannelMembers(serverId: server.serverId, channel: server.defaultChannelId)
                } else {
                    UserInfoManager.shared.prefetchUserInfos([conversation.conversationId])
                }
            }
            
            switch chat {
            case .p2p(let uid):
                navigationItem.title = UserInfoManager.shared[uid]?.nickname
            case let .circle(s, channel: c, thread: _):
                navigationItem.title = s.defaultChannelId == c.channelId ? s.name : c.name
            case .none:
                navigationItem.title = "聊天"
            }
        }
    }
    
    var conversation: EMConversation!
    
    private weak var chatManager: IEMChatManager? {
        EMClient.shared().chatManager
    }
    
    /// The object that manages autocomplete, from InputBarAccessoryView
    lazy var autocompleteManager: AutocompleteManager = { [unowned self] in
        let manager = AutocompleteManager(for: self.messageInputBar.inputTextView)
        manager.delegate = self
        manager.dataSource = self
        manager.tableView.maxVisibleRows = 5
        return manager
    }()
    
    lazy var attachmentManager: AttachmentManager = { [unowned self] in
      let manager = AttachmentManager()
      manager.delegate = self
      return manager
    }()
    
    lazy var hashtagAutocompletes: [AutocompleteCompletion] = {
        return chat.server?.channels?.compactMap({ channel in
            if (channel == chat.server?.defaultChannel) {
                return nil
            }
            return AutocompleteCompletion(text: channel.name, context: ["channelId": channel.channelId, "serverId": channel.serverId, "name": channel.name])
        }) ?? []
    }()
    
    fileprivate lazy var messages = [EMChatMessage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        EMClient.shared().chatManager?.add(self, delegateQueue: nil)
        
        configureMessageCollectionView()
        configureMessageInputBarForChat()
        
        var plugins: [InputPlugin] = [attachmentManager]
        
        // Configure AutocompleteManager
        if chat.isCircle {
            autocompleteManager.register(
              prefix: "@",
              with: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.systemBlue,
              ])
            autocompleteManager.register(prefix: "#", with: [
                .font: UIFont.preferredFont(forTextStyle: .body),
                .foregroundColor: UIColor.systemBlue
            ])
            autocompleteManager.maxSpaceCountDuringCompletion = 1 // Allow for autocompletes with a space
            
            // Set plugins
            plugins.append(autocompleteManager)
        }
        
        messageInputBar.inputPlugins = plugins
        
        loadMessage()
    }
    
    private func configureMessageCollectionView() {
        
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        
        layout?.setMessageIncomingAvatarPosition(.init(vertical: .messageLabelTop))
        layout?.setMessageOutgoingAvatarPosition(.init(vertical: .messageLabelTop))
//        layout?.setAvatarLeadingTrailingPadding(28.0)
        
        layout?.setMessageOutgoingAvatarSize(CGSize(width: 38, height: 38))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 38, height: 38))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.tintColor = .accent
        
        showMessageTimestampOnSwipeLeft = true
        scrollsToLastItemOnKeyboardBeginsEditing = true
//        maintainPositionOnKeyboardFrameChanged = true
        additionalBottomInset = 30
    }
    
    private func configureMessageInputBarForChat() {
        messageInputBar.setMiddleContentView(messageInputBar.inputTextView, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 52, animated: false)
        var bottomItems = [InputBarButtonItem.flexibleSpace]
        
        let photo = makeButton(named: "ic_photo")
        
        photo.onTouchUpInside { _ in
            self.showImagePickerControllerActionSheet()
        }
        
        bottomItems.append(photo)
        
        if chat.isCircle {
            
            let hashtag = makeButton(named: "ic_hashtag")
            hashtag.onTouchUpInside { [weak self] _ in
                self?.messageInputBar.inputTextView.insertText("#")
            }
            bottomItems.append(hashtag)
            
            let at = makeButton(named: "ic_at")
            at.onTouchUpInside { [weak self] _ in
                self?.messageInputBar.inputTextView.insertText("@")
            }
            bottomItems.append(at)
        }
        messageInputBar.setStackViewItems(bottomItems.reversed(), forStack: .bottom, animated: false)

        messageInputBar.shouldManageSendButtonEnabledState = false
        messageInputBar.sendButton.activityViewColor = .white
        messageInputBar.sendButton.backgroundColor = .accent
        messageInputBar.sendButton.layer.cornerRadius = 10
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .highlighted)
        messageInputBar.sendButton.setTitleColor(UIColor(white: 1, alpha: 0.3), for: .disabled)
        messageInputBar.sendButton.isEnabled = true
        messageInputBar.sendButton
            .onSelected { item in
                item.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            }.onDeselected { item in
                item.transform = .identity
            }
    }
    
    private func makeButton(named: String) -> InputBarButtonItem {
      InputBarButtonItem()
        .configure {
          $0.spacing = .fixed(10)
          $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
          $0.setSize(CGSize(width: 25, height: 25), animated: false)
          $0.tintColor = UIColor(white: 0.7, alpha: 1)
        }.onSelected {
          $0.tintColor = .accent
        }.onDeselected {
          $0.tintColor = UIColor(white: 0.7, alpha: 1)
        }
    }
    
    deinit {
        EMClient.shared().chatManager?.remove(self)
    }
        
    private func loadMessage() {
        
        conversation?.loadMessagesStart(fromId: messages.first?.messageId, count: pageCount, searchDirection: .up) { [weak self] aMessages, _ in
            if let ms = aMessages {
                UserInfoManager.shared.prefetchUserInfos(ms.map { $0.from })
                
                self?.messages.insert(contentsOf: ms, at: 0)
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
        
        let message = messages[indexPath.section]
        
        
        
        return cell
    }
    
}

extension ChatViewController: MessagesDataSource {
    
    func currentSender() -> MessageKit.SenderType {
        UserInfoManager.shared.ownUserInfo!
    }
        
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

extension ChatViewController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
      isTimeLabelVisible(at: indexPath) ? 40 : 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
        isAvatarViewVisible(at: indexPath) ? 20 : 0
    }
    
    func messageTimestampLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isFromCurrentSender(message: message) {
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            return NSAttributedString(string: df.string(from: message.sentDate), attributes: [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: 14)])
        }
        return nil
    }
    
//    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> CGFloat {
//      (isLastSectionVisible() && isFromCurrentSender(message: message)) ? 16 : 0
//    }
            
    func isFromCurrentSender(message: MessageType) -> Bool {
      message.sender.senderId == currentSender().senderId
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        if (indexPath.section == 0) {
            return true
        }
        
        let message = messages[indexPath.section]
        let preMessage = messages[indexPath.section - 1]
        
        // 5分钟之内的消息不显示时间戳
        return preMessage.sentDate.distance(to: message.sentDate) > 300
    }

    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
      guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].sender.senderId == messages[indexPath.section - 1].sender.senderId
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
      guard indexPath.section + 1 < messages.count else { return false }
      return messages[indexPath.section].sender.senderId == messages[indexPath.section + 1].sender.senderId
    }
    
    func isNextTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return isTimeLabelVisible(at: IndexPath(item: 0, section: indexPath.section + 1))
    }
    
    func isAvatarViewVisible(at indexPath: IndexPath) -> Bool {
        !isPreviousMessageSameSender(at: indexPath) || isTimeLabelVisible(at: indexPath)
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
            }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.backgroundColor = .secondarySystemBackground
        avatarView.isHidden = !isAvatarViewVisible(at: indexPath)
        avatarView.layer.borderWidth = 1
        avatarView.layer.borderColor = UIColor.accent.cgColor
        
        UserInfoManager.shared.fetchUserInfo(message.sender.senderId) { info in
            DispatchQueue.main.async {
                if let avatar = info?.avatarUrl {
                    avatarView.set(avatar: Avatar(image: nil, initials: avatar))
                }
            }
        }
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        accessoryView.subviews.forEach { $0.removeFromSuperview() }
        accessoryView.backgroundColor = .clear
        
        if isFromCurrentSender(message: message) {
            let message = messages[indexPath.section]
            
          let attr = NSAttributedString(
              string: message.status == .pending ? "准备发送" : message.status == .delivering ? "正在发送" : message.status == .succeed ? (message.isRead ? "已读" : "未读") : "发送失败",
              attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1), .foregroundColor: message.isRead ? UIColor.accent : message.status == .failed ? UIColor.red : UIColor.secondaryLabel])
            
            let label = UILabel()
            label.frame = accessoryView.bounds
            label.isUserInteractionEnabled = true
            label.attributedText = attr
            accessoryView.addSubview(label)
        }
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if isTimeLabelVisible(at: indexPath) {
            let text = message.sentDate.formatedStringForMessageCell
            return NSAttributedString(string: text, attributes: [.foregroundColor: UIColor.secondaryLabel, .font: UIFont.systemFont(ofSize: 14.0, weight: .medium)])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isAvatarViewVisible(at: indexPath) {
            return nil
        }
        
        let name = message.sender.displayName
        if name == "" {
            UserInfoManager.shared.fetchUserInfo(message.sender.senderId, forceUpdate: true) { [weak self] info in
                if info != nil {
                    self?.messagesCollectionView.reloadSections([indexPath.section])
                }
            }
        }
        return NSAttributedString(string: name, attributes: [.font: UIFont.preferredFont(forTextStyle: .footnote), .foregroundColor: UIColor.secondaryLabel])
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector {
        case .hashtag, .mention:
            return [.font: UIFont.preferredFont(forTextStyle: .body), .foregroundColor: UIColor.systemBlue]
        default:
            return [:]
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.mention, .hashtag]
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in _: MessagesCollectionView) -> MessageStyle {
      var corners: UIRectCorner = []

      if isFromCurrentSender(message: message) {
          
          corners.formUnion(.topLeft)
          corners.formUnion(.bottomLeft)
          
          if isAvatarViewVisible(at: indexPath) {
              corners.formUnion(.topRight)
          }
          
          if !isNextMessageSameSender(at: indexPath) {
              corners.formUnion(.bottomRight)
          } else {
              if isNextTimeLabelVisible(at: indexPath) {
                  corners.formUnion(.bottomRight)
              }
          }

      } else {
          
          corners.formUnion(.topRight)
          corners.formUnion(.bottomRight)
          
          if isAvatarViewVisible(at: indexPath) {
              corners.formUnion(.topLeft)
          }
          
          if !isNextMessageSameSender(at: indexPath) {
              corners.formUnion(.bottomLeft)
          } else {
              if isNextTimeLabelVisible(at: indexPath) {
                  corners.formUnion(.bottomLeft)
              }
          }
      }
        
        let color = isFromCurrentSender(message: message) ? UIColor.secondarySystemGroupedBackground : UIColor.accent
      return .custom { view in
          view.backgroundColor = color
          let radius: CGFloat = 8
          let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
          let mask = CAShapeLayer()
          mask.path = path.cgPath
          view.layer.mask = mask
      }
    }

}

extension ChatViewController: MessageCellDelegate {
    
}

///
///
/// Insert Message Helpers
extension ChatViewController {
    
    func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    func insertMessage(_ message: EMChatMessage) {
        
        DispatchQueue.main.async { [unowned self] in
            messages.append(message)
            
            messagesCollectionView.performBatchUpdates ({
                messagesCollectionView.insertSections([messages.count - 1])
                if messages.count >= 2 {
                    messagesCollectionView.reloadSections([messages.count - 2])
                }
            }) { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToLastItem()
                }
            }
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
 
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        if (attachmentManager.attachments.count > 0) {
            // 发消息
            for attachment in attachmentManager.attachments {
                guard case let .image(img) = attachment else {
                    continue
                }
                let body = EMImageMessageBody(data: img.pngData(), displayName: nil)
                let message = EMChatMessage(conversationID: conversation.conversationId, body: body, ext: nil)
                sendEMChatMessage(message)
            }
            
            inputBar.invalidatePlugins()
        }
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { _, range, _ in

          let substring = attributedText.attributedSubstring(from: range)
          let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
          print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        
        for component in components {
            var body: EMMessageBody = EMTextMessageBody(text: "unSupport")
            switch component {
                case let text as String:
                    body = EMTextMessageBody(text: text)
                case let image as UIImage:
                    body = EMImageMessageBody(data: image.pngData(), displayName: "[图片]")
                default:
                    break
            }
            
            let message = EMChatMessage(conversationID: chat.conversationId, body: body, ext: nil)
            sendEMChatMessage(message)
        }
        
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    fileprivate func sendEMChatMessage(_ message: EMChatMessage) {
        message.chatType = chat.EMChatType
        insertMessage(message)
        EMClient.shared().chatManager?.send(message, progress: nil) { _, _ in
            
            
        }
    }
}

extension ChatViewController: EMChatManagerDelegate {
    
    func messagesDidReceive(_ aMessages: [EMChatMessage]) {
        for message in aMessages where message.isBelong(to: chat) {
            insertMessage(message)
            
            EMClient.shared().chatManager?.sendMessageReadAck(message.messageId, toUser: message.from)
            conversation.markMessageAsRead(withId: message.messageId, error: nil)
        }
    }
    
    private func reload(message: EMChatMessage) {
        if let index = messages.firstIndex(where: { em in
            em.messageId == message.messageId
        }) {
            messagesCollectionView.reloadSections([index])
        }
    }
    
    func messagesDidDeliver(_ aMessages: [EMChatMessage]) {
        aMessages.forEach { m in
            reload(message: m)
        }
    }
    
    func messageStatusDidChange(_ aMessage: EMChatMessage, error aError: EMError?) {
        reload(message: aMessage)
    }
    
    func messageAttachmentStatusDidChange(_ aMessage: EMChatMessage, error aError: EMError?) {
        reload(message: aMessage)
    }
    
}

extension ChatViewController: AutocompleteManagerDelegate, AutocompleteManagerDataSource {
    
    func autocompleteManager(_: AutocompleteManager, autocompleteSourceFor prefix: String) -> [AutocompleteCompletion] {
      if prefix == "@" {
          return chat.server?.defaultChannel?.members?.compactMap({ u in
              UserInfoManager.shared[u.userId!]
          }).compactMap({ info in
              if let nickname = info.nickname, let id = info.userId {
                  return AutocompleteCompletion(text: nickname, context: ["id": id, "name": nickname])
              }
              return nil
          }) ?? []
      } else if prefix == "#" {
        return hashtagAutocompletes
      }
      return []
    }

    func autocompleteManager(
      _ manager: AutocompleteManager,
      tableView: UITableView,
      cellForRowAt indexPath: IndexPath,
      for session: AutocompleteSession)
      -> UITableViewCell
    {
      guard
        let cell = tableView
          .dequeueReusableCell(withIdentifier: AutocompleteCell.reuseIdentifier, for: indexPath) as? AutocompleteCell else
      {
        fatalError("Oops, some unknown error occurred")
      }
//      let users = SampleData.shared.senders
//      let id = session.completion?.context?["id"] as? String
//      let user = users.filter { $0.senderId == id }.first
//      if let sender = user {
//        cell.imageView?.image = SampleData.shared.getAvatarFor(sender: sender).image
//      }
//      cell.imageViewEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
//      cell.imageView?.layer.cornerRadius = 14
//      cell.imageView?.layer.borderColor = UIColor.primaryColor.cgColor
//      cell.imageView?.layer.borderWidth = 1
//      cell.imageView?.clipsToBounds = true
      cell.textLabel?.attributedText = manager.attributedText(matching: session, fontSize: 16)
      return cell
    }

    // MARK: - AutocompleteManagerDelegate

    func autocompleteManager(_: AutocompleteManager, shouldBecomeVisible: Bool) {
      setAutocompleteManager(active: shouldBecomeVisible)
    }

    // MARK: - AutocompleteManagerDelegate Helper

    func setAutocompleteManager(active: Bool) {
      let topStackView = messageInputBar.topStackView
      if active, !topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
        topStackView.insertArrangedSubview(autocompleteManager.tableView, at: topStackView.arrangedSubviews.count)
        topStackView.layoutIfNeeded()
      } else if !active, topStackView.arrangedSubviews.contains(autocompleteManager.tableView) {
        topStackView.removeArrangedSubview(autocompleteManager.tableView)
        topStackView.layoutIfNeeded()
      }
      messageInputBar.invalidateIntrinsicContentSize()
    }
    
}
