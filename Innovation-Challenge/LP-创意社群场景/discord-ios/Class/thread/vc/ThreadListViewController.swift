//
//  ThreadListViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/13.
//

import UIKit
import HyphenateChat
import MJRefresh

class ThreadListViewController: BaseViewController {

    @IBOutlet private weak var tableView: UITableView!
    
    private let chatType: ChatType
    
    private var result: EMCursorResult<EMChatThread>?
    private var lastMesageMap: [String: EMChatMessage] = [:]
    
    init(chatType: ChatType) {
        self.chatType = chatType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "子区列表"
        
        switch self.chatType {
        case .channel(serverId: let serverId, channelId: let channelId):
            EMClient.shared().circleManager?.fetchChannelDetail(serverId, channelId: channelId) { channel, _ in
                if let channelName = channel?.name {
                    self.subtitle = "# \(channelName)"
                }
            }
        default:
            break
        }
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "ThreadListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadData(refresh: true)
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            self?.loadData(refresh: false)
        })
        self.loadData(refresh: true)
    }
    
    private func loadData(refresh: Bool) {
        let cursor = refresh ? nil : self.result?.cursor
        EMClient.shared().threadManager?.getChatThreadsFromServer(withParentId: self.chatType.conversationId, cursor: cursor, pageSize: 20) { result, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
                self.tableView.mj_header?.endRefreshing()
                self.tableView.mj_footer?.endRefreshing()
            } else {
                if let threads = result?.list {
                    var map: [String: EMChatThread] = [:]
                    var threadIds: [String] = []
                    for thread in threads {
                        map[thread.threadId] = thread
                        threadIds.append(thread.threadId)
                        if let threadId = thread.threadId, let messageId = thread.messageId, let message = EMClient.shared().chatManager?.getMessageWithMessageId(messageId) {
                            self.lastMesageMap[threadId] = message
                        }
                    }
                    EMClient.shared().threadManager?.getLastMessageFromSever(withChatThreads: threadIds) { lastMessageMap, error in
                        if let error = error {
                            Toast.show(error.errorDescription, duration: 2)
                        } else if let lastMessageMap = lastMessageMap {
                            for (key, message) in lastMessageMap {
                                self.lastMesageMap[key] = message
                            }
                        }
                        if refresh || self.result == nil {
                            self.result = result
                        } else if let list = result?.list {
                            var oldList = self.result!.list ?? []
                            oldList.append(contentsOf: list)
                            self.result!.list = oldList
                            self.result?.cursor = result?.cursor
                        }
                        self.tableView.reloadData()
                        
                        self.tableView.mj_header?.endRefreshing()
                        if result?.list?.count ?? 0 < 20 {
                            self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                            self.tableView.mj_footer?.isHidden = true
                        } else {
                            self.tableView.mj_footer?.endRefreshing()
                            self.tableView.mj_footer?.isHidden = false
                        }
                    }
                } else {
                    self.tableView.mj_header?.endRefreshing()
                    self.tableView.mj_footer?.endRefreshing()
                }
            }
        }
    }
}

extension ThreadListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.result?.list?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ThreadListTableViewCell {
            let thread = self.result?.list?[indexPath.row]
            cell.chatThread = thread
            if let threadId = thread?.threadId {
                cell.lastMessage = self.lastMesageMap[threadId]
            } else {
                cell.lastMessage = nil
            }
        }
        return cell
    }
}

extension ThreadListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let thread = self.result?.list?[indexPath.row]
        if let threadId = thread?.threadId {
            EMClient.shared().threadManager?.joinChatThread(threadId) { [weak self] thread, error in
                guard let self = self else {
                    return
                }
                if let error = error, error.code != .userAlreadyExist {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    if let tid = self.chatType.createThreadId(threadId: threadId) {
                        let vc = ChatViewController(chatType: .thread(threadId: tid))
                        if let subtitle = self.subtitle {
                            vc.subtitle = subtitle
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}
