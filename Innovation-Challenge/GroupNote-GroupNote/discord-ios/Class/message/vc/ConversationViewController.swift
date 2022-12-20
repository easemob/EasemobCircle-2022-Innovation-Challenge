//
//  ConversationViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/29.
//

import UIKit
import HyphenateChat

class ConversationViewController: UIViewController {

    @IBOutlet weak var noDataView: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var conversations: [EMConversation]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "ConversationCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        EMClient.shared().chatManager?.add(self, delegateQueue: nil)
        EMClient.shared().presenceManager?.add(self, delegateQueue: nil)
        self.reloadData()
    }
    
    private func reloadData() {
        var unreadCount: Int32 = 0
        if var conversations = EMClient.shared().chatManager?.getAllConversations() {
            for i in (0..<conversations.count).reversed() where conversations[i].type != .chat {
                conversations.remove(at: i)
            }
            self.conversations = conversations
            var requestList: [String] = []
            for conversation in conversations {
                requestList.append(conversation.conversationId)
                unreadCount += conversation.unreadMessagesCount
            }
            if requestList.count > 0 {
                UserInfoManager.share.queryUserInfo(userIds: requestList) {
                    self.tableView.reloadData()
                }
                UserOnlineManager.shared.subscribe(members: requestList) {
                    self.tableView.reloadData()
                }
            }
        } else {
            self.conversations = nil
        }
        self.tableView.reloadData()
        self.noDataView.isHidden = (self.conversations?.count ?? 0) > 0
        NotificationCenter.default.post(name: EMMessageUnreadCountChange, object: unreadCount)
    }
    
    deinit {
        EMClient.shared().chatManager?.remove(self)
        EMClient.shared().presenceManager?.remove(self)
    }
}

extension ConversationViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ConversationCell {
            let item = self.conversations?[indexPath.row]
            cell.conversation = item
            if item?.type == .chat, let userId = item?.conversationId {
                cell.userInfo = UserInfoManager.share.userInfo(userId: userId)
                cell.state = UserOnlineManager.shared.checkIsOnline(userId: userId) ? .online : .offline
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var chatType: ChatType?
        let item = self.conversations?[indexPath.row]
        if item?.type == .chat, let userId = item?.conversationId {
            chatType = .single(userId: userId)
        }
        if let chatType = chatType {
            item?.markAllMessages(asRead: nil)
            self.reloadData()
            let vc = ChatViewController(chatType: chatType)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ConversationViewController: EMChatManagerDelegate {
    func conversationListDidUpdate(_ aConversationList: [EMConversation]) {
        self.reloadData()
    }
    
    func messagesInfoDidRecall(_ aRecallMessagesInfo: [EMRecallMessageInfo]) {
        self.reloadData()
    }
    
    func onConversationRead(_ from: String, to: String) {
        self.reloadData()
    }
    
    func messagesDidReceive(_ aMessages: [EMChatMessage]) {
        self.reloadData()
    }
}

extension ConversationViewController: EMPresenceManagerDelegate {
    func presenceStatusDidChanged(_ presences: [EMPresence]) {
        for presence in presences {
            for cell in self.tableView.visibleCells {
                if let cell = cell as? ConversationCell, cell.userInfo?.userId == presence.publisher {
                    cell.state = presence.userStatus
                    break
                }
            }
        }
    }
}
