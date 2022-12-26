//
//  MessageServerChannelCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/29.
//

import UIKit
import HyphenateChat

class MessageServerChannelCell: UITableViewCell {

    @IBOutlet private weak var privateImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var foldImageView: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var unreadView: UIView!
    @IBOutlet private weak var unreadCountLabel: UILabel!
    
    var isFold = true {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.foldImageView.transform = CGAffineTransform(rotationAngle: self.isFold ? 0 : CGFloat.pi)
            }
        }
    }
    
    var channel: EMCircleChannel? {
        didSet {
            self.nameLabel.text = channel?.name
            self.privateImageView.image = UIImage(named: channel?.type == .private ? "#_channel_private" : "#_channel_public")
            if let channelId = self.channel?.channelId, let conversation = EMClient.shared.chatManager?.getConversation(channelId, type: .groupChat, createIfNotExist: true, isThread: false, isChannel: true) {
                if conversation.unreadMessagesCount > 0 {
                    self.unreadView.isHidden = false
                    self.unreadCountLabel.text = "\(conversation.unreadMessagesCount)"
                } else {
                    self.unreadView.isHidden = true
                }
            } else {
                self.unreadView.isHidden = true
            }
        }
    }
    
    var threads: [EMChatThread]?
    var hasNoMoreData: Bool?
    
    var channelClickHandle: ((_ channel: EMCircleChannel) -> Void)?
    var foldClickHandle: ((_ channel: EMCircleChannel) -> Void)?
    var threadClickHandle: ((_ thread: EMChatThread) -> Void)?
    var moreClickHandle: ((_ channel: EMCircleChannel) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "MessageServerThreadCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.register(UINib(nibName: "MessageServerThreadListFooter", bundle: nil), forHeaderFooterViewReuseIdentifier: "footer")
    }
    
    @IBAction func channelAction() {
        if let channel = channel {
            self.channelClickHandle?(channel)
        }
    }
    
    @IBAction func foldAction() {
        if let channel = channel {
            self.foldClickHandle?(channel)
        }
    }
    
    func setThreads(threads: [EMChatThread], hasNoMoreData: Bool) {
        self.tableView.isHidden = self.isFold
        if self.isFold {
            return
        }
        self.threads = threads
        self.hasNoMoreData = hasNoMoreData
        self.tableView.reloadData()
    }
}

extension MessageServerChannelCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isFold {
            return 0
        }
        return self.threads?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? MessageServerThreadCell {
            cell.nameLabel.text = self.threads?[indexPath.row].threadName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if self.hasNoMoreData ?? true {
            return nil
        }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer")
        if let view = view as? MessageServerThreadListFooter {
            view.clickHandle = { [unowned self] in
                if let channel = self.channel {
                    self.moreClickHandle?(channel)
                }
            }
        }
        return view
    }
}

extension MessageServerChannelCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let item = self.threads?[indexPath.row] {
            self.threadClickHandle?(item)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.hasNoMoreData ?? true {
            return 0
        }
        return 32
    }
}
