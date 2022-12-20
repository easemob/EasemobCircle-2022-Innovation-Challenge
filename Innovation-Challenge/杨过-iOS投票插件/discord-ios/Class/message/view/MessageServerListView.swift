//
//  MessageServerListView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/24.
//

import UIKit
import HyphenateChat
import Kingfisher

class MessageServerListView: UIView {

    public enum SelectType {
    case conversation
    case add
    case serverItem(serverId: String)
    }
    
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: MessageServerListLayout())
    
    public var didSelectedItem: ((_ type: SelectType) -> Void)?
    
    private var _selectType: SelectType = .conversation
    public var selectType: SelectType {
        return _selectType
    }
    
    private var dataList: [EMCircleServer] = []
    private var cursor: String?
    
    private var unreadCount: Int32?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selfInit()
    }
    
    private func selfInit() {
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: 66, height: 72)
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.register(UINib(nibName: "MessageItemCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        self.addSubview(self.collectionView)
    
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(16)
            make.left.right.bottom.equalTo(0)
        }
        
        EMClient.shared().circleManager?.add(serverDelegate: self, queue: nil)
        EMClient.shared().addMultiDevices(delegate: self, queue: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvServerAddNotification(_:)), name: EMCircleDidCreateServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvServerAddNotification(_:)), name: EMCircleDidJoinedServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvExitedServerNotification(_:)), name: EMCircleDidExitedServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvUpdateServerNotification(_:)), name: EMCircleDidUpdateServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvDestroyServerNotification(_:)), name: EMCircleDidDestroyServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvUnreadCountChangeNotification(_:)), name: EMMessageUnreadCountChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvShouldSelectedServerNotification(_:)), name: MainShouldSelectedServer, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvJoinChannelNotification(_:)), name: EMCircleDidJoinChannel, object: nil)
        
        self.loadData()
    }
    
    private func loadData() {
        EMClient.shared().circleManager?.fetchJoinedServers(20, cursor: self.cursor) { result, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
                return
            }
            if let dataList = result?.list as? [EMCircleServer] {
                ServerInfoManager.shared.saveServerInfo(servers: dataList)
                self.dataList.append(contentsOf: dataList)
                self.cursor = result?.cursor
            }
            
            self.collectionView.reloadData()
            if let cursor = self.cursor, cursor.count > 0, result?.list?.count ?? 0 >= 20 {
                self.loadData()
            }
        }
    }
    
    @objc private func conversationAction() {
        self._selectType = .conversation
        self.didSelectedItem?(.conversation)
    }
    
    @objc private func addAction() {
        self._selectType = .add
        self.didSelectedItem?(.add)
    }
    
    private func removeServer(serverId: String) {
        for i in 0..<self.dataList.count where self.dataList[i].serverId == serverId {
            self.dataList.remove(at: i)
            self.collectionView.performBatchUpdates {
                self.collectionView.deleteItems(at: [IndexPath(item: i + 1, section: 0)])
            }
            break
        }
        switch self.selectType {
        case .serverItem(serverId: let sid):
            if serverId == sid {
                self._selectType = .conversation
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
                }
                self.didSelectedItem?(.conversation)
            }
        default:
            break
        }
    }
    
    @objc private func didRecvServerAddNotification(_ notification: Notification) {
        if let server = notification.object as? EMCircleServer {
            self.dataList.append(server)
            self.collectionView.performBatchUpdates {
                self.collectionView.insertItems(at: [IndexPath(item: self.dataList.count, section: 0)])
            }
        }
    }
    
    @objc private func didRecvUpdateServerNotification(_ notification: Notification) {
        if let server = notification.object as? EMCircleServer {
            for i in 0..<self.dataList.count where self.dataList[i].serverId == server.serverId {
                self.dataList[i].icon = server.icon
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadItems(at: [IndexPath(item: i + 1, section: 0)])
                }
                break
            }
        }
    }
    
    @objc private func didRecvExitedServerNotification(_ notification: Notification) {
        if let serverId = notification.object as? String {
            self.removeServer(serverId: serverId)
        }
    }
    
    @objc private func didRecvDestroyServerNotification(_ notification: Notification) {
        if let serverId = notification.object as? String {
            self.removeServer(serverId: serverId)
            ServerInfoManager.shared.remove(serverId: serverId)
        }
    }
    
    @objc private func didRecvUnreadCountChangeNotification(_ notification: Notification) {
        self.unreadCount = notification.object as? Int32
        if let cell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: 0)) as? MessageItemCell {
            cell.unreadCount = self.unreadCount
        }
    }
    
    @objc private func didRecvShouldSelectedServerNotification(_ notification: Notification) {
        if let serverId = notification.object as? String {
            for i in 0..<self.dataList.count where self.dataList[i].serverId == serverId {
                self._selectType = .serverItem(serverId: serverId)
                self.didSelectedItem?(self._selectType)
                self.collectionView.reloadData()
                self.collectionView.scrollToItem(at: IndexPath(item: i + 1, section: 0), at: .centeredVertically, animated: false)
                break
            }
        }
    }
    
    @objc private func didRecvJoinChannelNotification(_ notification: Notification) {
        guard let channel = notification.object as? EMCircleChannel else {
            return
        }
        for server in self.dataList where channel.serverId == server.serverId {
            return
        }
        
        EMClient.shared().circleManager?.fetchServerDetail(channel.serverId, completion: { server, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else if let server = server {
                self.dataList.append(server)
                self.collectionView.performBatchUpdates {
                    self.collectionView.insertItems(at: [IndexPath(item: self.dataList.count, section: 0)])
                }
            }
        })
    }
    
    deinit {
        EMClient.shared().circleManager?.remove(serverDelegate: self)
        EMClient.shared().remove(self)
        NotificationCenter.default.removeObserver(self)
    }
}

extension MessageServerListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count + 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? MessageItemCell {
            if indexPath.item == 0 {
                cell.image = UIImage(named: "message_item_conversation")
                cell.bgShow = self.selectType == .conversation
                cell.unreadCount = self.unreadCount
            } else if indexPath.item > self.dataList.count {
                cell.image = UIImage(named: "message_server_add")
                cell.bgShow = false
                cell.unreadCount = nil
            } else {
                let item = self.dataList[indexPath.item - 1]
                cell.imageUrl = item.icon
                cell.unreadCount = nil
                switch self.selectType {
                case .serverItem(serverId: let serverId):
                    cell.bgShow = item.serverId == serverId
                default:
                    cell.bgShow = false
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            self._selectType = .conversation
        } else if indexPath.item > self.dataList.count {
            self.didSelectedItem?(.add)
            return
        } else {
            let serverId = self.dataList[indexPath.item - 1].serverId
            self._selectType = .serverItem(serverId: serverId)
        }
        self.didSelectedItem?(self._selectType)
        self.collectionView.reloadData()
    }
}

extension MessageServerListView.SelectType {
    static func == (lhs: MessageServerListView.SelectType, rhs: MessageServerListView.SelectType) -> Bool {
        switch (lhs, rhs) {
        case (.conversation, .conversation):
            return true
        case (.add, .add):
            return true
        case (.serverItem(serverId: let l), .serverItem(serverId: let r)):
            return l == r
        default:
            return false
        }
    }
}

extension MessageServerListView: EMCircleManagerServerDelegate {
    func onServerDestroyed(_ serverId: String, initiator: String) {
        self.removeServer(serverId: serverId)
        ServerInfoManager.shared.remove(serverId: serverId)
    }
    
    func onMemberRemoved(fromServer serverId: String, members: [String]) {
        guard let currentUserId = EMClient.shared().currentUsername, members.firstIndex(of: currentUserId) != nil else {
            return
        }
        self.removeServer(serverId: serverId)
    }
    
    func onServerUpdated(_ event: EMCircleServerEvent) {
        for i in self.dataList where i.serverId == event.serverId {
            i.ext = event.serverCustom
            i.name = event.serverName
            i.icon = event.serverIconUrl
            ServerInfoManager.shared.saveServerInfo(servers: [i])
            break
        }
        self.collectionView.reloadData()
    }
}

extension MessageServerListView: EMMultiDevicesDelegate {
    func multiDevicesCircleServerEventDidReceive(_ aEvent: EMMultiDevicesEvent, serverId: String, ext aExt: Any?) {
        switch aEvent {
        case .circleServerCreate, .circleServerJoin:
            ServerInfoManager.shared.getServerInfo(serverId: serverId, refresh: false) { server, _ in
                if let server = server {
                    self.dataList.append(server)
                    self.collectionView.performBatchUpdates {
                        self.collectionView.insertItems(at: [IndexPath(item: self.dataList.count, section: 0)])
                    }
                }
            }
        case .circleServerDestroy:
            self.removeServer(serverId: serverId)
            ServerInfoManager.shared.remove(serverId: serverId)
        case .circleServerExit:
            self.removeServer(serverId: serverId)
        default:
            break
        }
    }
}
