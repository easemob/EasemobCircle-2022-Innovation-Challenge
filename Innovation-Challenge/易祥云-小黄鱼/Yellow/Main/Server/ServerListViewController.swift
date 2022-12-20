//
//  ViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/22.
//

import UIKit
import HyphenateChat
import Alamofire
import SPIndicator
import MultipeerConnectivity
import PermissionsKit
import LocationWhenInUsePermission
import CoreLocation
import LeanCloud
import SPAlert
import BadgeHub

extension Notification.Name {
    
    static let conversationUnreadCount = Notification.Name.init("conversationUnreadCount")
}

extension ServerListViewController: EMChatManagerDelegate {
    
    private func caculateUnreadCount() {
        guard let chatManager = EMClient.shared().chatManager else {
            return
        }
        
        let allConversations = chatManager.getAllConversations() ?? []
        
        let unreadCount = allConversations.filter { $0.type == .chat }.reduce(0, { $0 + $1.unreadMessagesCount})
        
        // 发送通知出去
        NotificationCenter.default.post(Notification(name: .conversationUnreadCount, object: unreadCount))
    }
    
    func conversationListDidUpdate(_ aConversationList: [EMConversation]) {
        caculateUnreadCount()
    }
    
    func messagesInfoDidRecall(_ aRecallMessagesInfo: [EMRecallMessageInfo]) {
        caculateUnreadCount()
    }
    
    func messagesDidReceive(_ aMessages: [EMChatMessage]) {
        caculateUnreadCount()
    }
    
    func onConversationRead(_ from: String, to: String) {
        caculateUnreadCount()
    }
}

class ServerListViewController: ServerTableViewController, ServerSearchResultViewControllerDelegate {

    fileprivate var servers = [EMCircleServer]()
        
    lazy var refreshControl = UIRefreshControl()
    
    private var hub: BadgeHub!
    
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        return manager
    }()
    
    private var searchTask: Task<[SearchServerResult]?, Never>?
    
    fileprivate var nearyServer: SearchServerResult?
    fileprivate var location: CLLocation? {
        didSet {
            nearyServer = nil
        }
    }
    
    lazy var searchResultViewController = ServerSearchResultViewController()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        EMClient.shared().chatManager?.add(self, delegateQueue: .main)
        
        searchResultViewController.delegate = self
        
        title = "感兴趣的社群"
        
        modalPresentationStyle = .custom
        
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = UISearchController(searchResultsController: searchResultViewController)
        navigationItem.searchController?.searchResultsUpdater = self
        navigationItem.searchController?.obscuresBackgroundDuringPresentation = true
        
        tableView?.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        
        tableView?.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        Permission.locationWhenInUse.request { [weak self] in
            if Permission.locationWhenInUse.status == .authorized {
                //
                self?.locationManager.delegate = self
                self?.locationManager.startUpdatingLocation()
            }
        }
                
        let button = UIButton(type: .custom)
        
        button.setImage(UIImage(named: "logo"), for: .normal)
        button.alpha = 0.0
        button.addTarget(self, action: #selector(onTapLogoButton(_:)), for: .touchUpInside)
        UIView.animate(withDuration: 0.5, delay: 0.0) {
            button.alpha = 1.0
        }
        
        let leftItem = UIBarButtonItem(customView: button)
        navigationItem.leftBarButtonItem = leftItem
        
        hub = BadgeHub(view: button)
        hub.setCircleAtFrame(CGRect(x: 36, y: -3, width: 20, height: 20))
        hub.setMaxCount(to: 99)
        hub.setCircleColor(.red, label: .white)
        
        NotificationCenter.default.addObserver(forName: .conversationUnreadCount, object: nil, queue: .main) { [weak self] n in
            guard let unreadCount = n.object as? Int else {
                return
            }
            self?.hub.setCount(unreadCount)
        }
        
        refreshControl.beginRefreshing()
        
        Task {
            // 登录
            try? await loginIfEMNeeded()
            // 加入官方社群
            await joinOfficialServerIfNeeded()
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.refresh(self.refreshControl)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc func onTapLogoButton(_ sender: UIButton) {
        performSegue(withIdentifier: "showConversationVC", sender: nil)
    }
    
    @objc func refresh(_ sender: UIRefreshControl?) {
        
        Task {
            
            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.searchController?.searchBar.isUserInteractionEnabled = false
            }
            
            await assembleData()
            
            DispatchQueue.main.async { [weak self] in
                self?.navigationItem.searchController?.searchBar.isUserInteractionEnabled = true
                sender?.endRefreshing()
                self?.tableView.reloadData()
            }
        }
        
    }
    
    func assembleData() async {
        servers = await EM.fetchAll { cursor in
            await EMClient.shared().circleManager?.fetchJoinedServers(20, cursor: cursor)
        }
        
        if let s = servers.first {
            await s.loadChannels()
        }
        
        Task {
            for i in 0..<servers.count {

                let s = servers[i]
                
                if s.channels != nil {
                    continue
                }
                
                await s.loadChannels()
                
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadSections([i], with: .automatic)
                }
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        servers.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let server = servers[section]
        
        return server.channels?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let server = servers[indexPath.section]
        
        if (indexPath.row == 0) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CircleDefaultChannelCell.identifier) as? CircleDefaultChannelCell else {
                fatalError()
            }
            cell.configure(server)
            
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CircleChannelCell.identifier) as? CircleChannelCell , let channel = server.channels?[indexPath.row] else {
            fatalError()
        }
        cell.configure(channel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let server = servers[indexPath.section]
        let vc = ChannelDetailTableViewController(server: server, channel: server.channels![indexPath.row])
        
        present(UINavigationController(rootViewController: vc), animated: true)
    }
        
    func didSelect(_ server: EMCircleServer, at indexPath: IndexPath) {
        // 判断有没有加入到server
        EMClient.shared().circleManager?.checkSelfIs(inServer: server.serverId, completion: { [weak self] isIn, err in
            if err != nil {
                SPAlert.present(message: "连接环信超时，请重试 \(err!.localizedDescription)", haptic: .error)
                return
            }
            if isIn {
                //
                let vc = ChatViewController.newInstanceFromStoryboard(with: server, channel: server.channels![0])
                self?.navigationController?.pushViewController(vc, animated: true)
            } else {
                let ac = UIAlertController(title: "是否加入 [\(server.name)] 社群？", message: "加入社群可实时收取社群最新消息，和社群内其他小伙伴随时畅聊", preferredStyle: .actionSheet)

                ac.addAction(UIAlertAction(title: "加入", style: .default) { _ in
                    EMClient.shared().circleManager?.joinServer(server.serverId, completion: { s, err in
                        self?.refresh(nil)
                        if err == nil {
                            let vc = ChatViewController.newInstanceFromStoryboard(with: server, channel: server.channels![0])
                            self?.show(vc, sender: nil)
                        } else {
                            SPAlert.present(message: "加入\(server.name)社群失败，请重试", haptic: .error)
                        }
                    })
                })
                ac.addAction(UIAlertAction(title: "暂不", style: .cancel))

                self?.present(ac, animated: true)
            }
        })
    }
    
    func didSelect(_ channel: EMCircleChannel, at indexPath: IndexPath) {
        
        if channel.isIn {
            let server = servers[indexPath.section]
            let vc = ChatViewController.newInstanceFromStoryboard(with: server, channel: channel)
            show(vc, sender: nil)
        } else {
            let ac = UIAlertController(title: nil, message: "加入频道[\(channel.name)]立即开始热聊?", preferredStyle: .actionSheet)

            ac.addAction(UIAlertAction(title: "加入", style: .default) { _ in
                EMClient.shared().circleManager?.joinChannel(channel.serverId, channelId: channel.channelId, completion: { [weak self] _, err in
                    if err != nil {
                        SPAlert.present(message: "加入频道失败请重试", haptic: .error)
                    } else {
//                        let vc = ChatViewController.newInstanceFromStoryboard(with: .channel(channel))
//                        self?.show(vc, sender: nil)
                        channel.isIn = true
                        Task {
                            await channel.loadMembers()
                            
                            DispatchQueue.main.async {
                                guard let server = self?.servers[indexPath.section] else { return }
                                
                                let vc = ChannelDetailTableViewController(server: server, channel: channel)
                                
                                self?.present(UINavigationController(rootViewController: vc), animated: true)
                            }
                        }
                        self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                })
            })
            ac.addAction(UIAlertAction(title: "取消", style: .cancel))

            present(ac, animated: true)
        }
    }
    
}

extension ServerListViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let server = servers[indexPath.section]
        if indexPath.row == 0 {
            didSelect(server, at: indexPath)
        } else {
            didSelect(server.channels![indexPath.row], at: indexPath)
        }
    }
}

extension ServerListViewController: UISearchResultsUpdating {
 
    func updateSearchResults(for searchController: UISearchController) {
        if !searchController.isActive {
            searchResultViewController.searchResults = nil
        } else {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.perform(#selector(search), with: self, afterDelay: 0.3)
        }
    }
    
    @objc func search() {
        
        searchTask?.cancel()
        guard let text = navigationItem.searchController?.searchBar.text else {
            return
        }
        
        searchTask = Task { () -> [SearchServerResult]? in
            
            let searchResults = searchResultViewController.searchResults
            
            var results = [SearchServerResult]()
            if text.isEmpty {
                return results
            }
            
            var serverIds = [String]()
            
            // 🚩本地
            // 先筛选本地的serve
            let localServers = servers.filter { $0.name.contains(text)}
            
            localServers.forEach { s in
                serverIds.append(s.serverId)
            }
            
            // 过滤本地channel
            let localChannels = servers.compactMap { $0.channels }.flatMap { $0 }.filter {
                $0.name.contains(text) || ($0.desc?.contains(text) ?? false)
            }.map { CircleSearchResultLocal.channel($0) }
            
            if !localServers.isEmpty || !localChannels.isEmpty {
                results.append(.local(localServers.map { .server($0) } + localChannels))
            }
            
            if Task.isCancelled {
                return searchResults
            }
            
            // 🚩网络
            let r = await EMClient.shared().circleManager?.fetchServers(withKeyword: text)
            if let servers = (r?.0?.filter { !serverIds.contains($0.serverId) }), !servers.isEmpty {
                for s in servers {
                    await s.loadChannels()
                }
                results.append(.remote(servers))
                serverIds.append(contentsOf: servers.map { $0.serverId })
            }
            if Task.isCancelled {
                return searchResults
            }
            
            // 🚩附近
            // step 1. 读到自己的location 高德/系统
            if let s = nearyServer {
                results.append(s)
            } else {
                if let geo = (location.map { LCGeoPoint(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }) {
                    
                    // step 2. 去 lc 搜索对应的channelId
                    let query = LCQuery(className: "Channel")

                    try? query.where("location",
                        .locatedNear(geo, minimal: .init(value: 0, unit: .kilometer), maximal: .init(value: 5, unit: .kilometer))
                    )
                    
                    query.limit = 1
                    let result = query.find()
                    
                    if result.isSuccess {
                        if let objects = result.objects, !objects.isEmpty {
                            
                            var nearbyServers = [String: EMCircleServer]()
                            
                            // step 3. 去 circle manager 拿到channel的详情
                            for obj in objects {
                                if !Task.isCancelled, let serverId = obj.get("serverId")?.stringValue, !serverIds.contains(serverId) {
                                    let r = await EMClient.shared().circleManager?.fetchServerDetail(serverId)
                                    if let server = r?.0 {
                                        await server.loadChannels()
                                        nearbyServers[serverId] = server
                                    }
                                }
                            }
                            
                            if !Task.isCancelled && !nearbyServers.values.isEmpty {
                                
                                nearyServer = .nearby(nearbyServers.values.reversed())
                                results.append(nearyServer!)
                            }
                        }
                    }
                    
                    if Task.isCancelled {
                        return searchResults
                    }
                }
            }
            
                        
            return results
        }
        
        Task {
            searchResultViewController.searchResults = await searchTask?.value
        }
        
    }
    
}

extension ServerListViewController: CLLocationManagerDelegate {
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
        if location != nil {
            manager.stopUpdatingLocation()
        }
    }
}
