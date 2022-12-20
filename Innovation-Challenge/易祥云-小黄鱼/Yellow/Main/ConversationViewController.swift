//
//  ConversationViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/30.
//

import UIKit
import HyphenateChat
import BadgeSwift
import EmptyDataSet_Swift

private struct AssociatedKeys {
    
    static var kUserInfo = "kUserInfo"
    
}

extension EMConversation {
    
    //  确认已经单独请求组装过了
    var user: EMUserInfo? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.kUserInfo) as? EMUserInfo
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.kUserInfo, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension ConversationViewController: EMChatManagerDelegate {
    
    func conversationListDidUpdate(_ aConversationList: [EMConversation]) {
        reloadData()
    }
    
    func messagesInfoDidRecall(_ aRecallMessagesInfo: [EMRecallMessageInfo]) {
        reloadData()
    }
    
    func messagesDidReceive(_ aMessages: [EMChatMessage]) {
        reloadData()
    }
    
    func onConversationRead(_ from: String, to: String) {
        reloadData()
    }
}

class ConversationViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    
    fileprivate var chatManager: IEMChatManager {
        return EMClient.shared().chatManager!
    }
    
    private(set) var unreadCount: Int32 = 0
    
    fileprivate var conversations = [EMConversation]()
    
    private var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatManager.add(self, delegateQueue: nil)

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "会话"
        
        tableView?.separatorStyle = .singleLine
        tableView?.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChange(_:)), for: .valueChanged)
        
        refreshControl.beginRefreshing()
        reloadData()
        
        tableView?.tableFooterView = UIView()
        tableView?.emptyDataSetView({ view in
            view.titleLabelString(NSAttributedString(string: "暂无会话"))
                .detailLabelString(NSAttributedString(string: "您可以去查看旁边的人或者搜索附近的社群加入频道和鱼友愉快的聊天🚀"))
                .buttonTitle(NSAttributedString(string: "搜索旁边的人", attributes: [.foregroundColor: UIColor.systemBlue]), for: .normal)
                .didTapDataButton { [weak self] in
                    self?.performSegue(withIdentifier: "showNearybySearchVc", sender: nil)
                }
        })
    }
        
    deinit {
        chatManager.remove(self)
    }
    
    @objc func refreshControlValueChange(_ sender: UIRefreshControl) {
        reloadData()
    }
    
    private func reloadData() {
        
        Task {
            await assembleData()
            
            DispatchQueue.main.async { [unowned self] in
                
                refreshControl.endRefreshing()
                tableView?.reloadData()
            }
        }
    }
    
    private func assembleData() async {
        
        let allConversations = chatManager.getAllConversations() ?? []
        
        var tempConerstaions = [EMConversation]()
        
        unreadCount = 0
        
        for c in allConversations {
            if c.type == .chat {
                c.user = try? await UserInfoManager.shared.fetchUserInfo(c.conversationId!)
                unreadCount += c.unreadMessagesCount
                tempConerstaions.append(c)
            }
        }
        
        conversations = tempConerstaions
        // 发送通知出去
        NotificationCenter.default.post(Notification(name: .conversationUnreadCount, object: unreadCount))
    }
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier) as? ConversationTableViewCell else {
            fatalError()
        }

        cell.configure(with: conversations[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let c = conversations[indexPath.row]
        
        c.markAllMessages(asRead: nil)
        reloadData()
        
        let vc = ChatViewController.newInstanceFromStoryboard(with: c.conversationId)

        show(vc, sender: nil)
    }
}

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationCell"
    
    @IBOutlet weak var avatarContainerView: UIView?
    @IBOutlet weak var avatarLabel: UILabel?
    @IBOutlet weak var nicknameLabel: UILabel?
    @IBOutlet weak var previewLabel: UILabel?
    @IBOutlet weak var unreadcountLabel: BadgeSwift?
    @IBOutlet weak var timestampLabel: UILabel?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarContainerView?.layer.cornerRadius = 8
    }
    
    func configure(with conversation: EMConversation) {
        
        avatarLabel?.text = conversation.user?.avatarUrl
        nicknameLabel?.text = conversation.user?.nickname
        unreadcountLabel?.isHidden = conversation.unreadMessagesCount == 0
        unreadcountLabel?.text = conversation.unreadMessagesCount > 99 ? "99+": "\(conversation.unreadMessagesCount)"
        timestampLabel?.text = conversation.lastReceivedMessage()?.sentDate.formatedStringForMessageCell
        
        previewLabel?.text = nil
        previewLabel?.attributedText = nil
        
        let body = conversation.latestMessage.body
        
        switch body {
        case let textBody as EMTextMessageBody:
            previewLabel?.text = textBody.text
        case is EMImageMessageBody:
            previewLabel?.text = "[图片]"
        case is EMCustomMessageBody:
            previewLabel?.text = "旁边的人拍了拍你"
        default:
            previewLabel?.text = "[请下载最新版本]"
        }
    }
}
