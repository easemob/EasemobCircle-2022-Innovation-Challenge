//
//  SquareViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import UIKit
import HyphenateChat
import MJRefresh

class SquareViewController: UIViewController {
    
    @IBOutlet private weak var topBgImageView: UIImageView!
    @IBOutlet private weak var collectionView: UICollectionView!
    private let searchView = SquareSearchView(frame: CGRect(x: 0, y: 0, width: 300, height: 48))
    @IBOutlet private weak var noDataView: UIView!
    
    private var recommendServers: [EMCircleServer]?
    private var searchResult: [EMCircleServer]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        self.view.insertSubview(self.searchView, aboveSubview: self.collectionView)
        self.searchView.didBeginEditing = { [weak self] in
            self?.collectionView.reloadData()
            UIView.animate(withDuration: 0.3) {
                self?.updateCollectionViewContentInset()
                self?.collectionView.contentOffset.y = 0
            }
        }
        self.searchView.didBeginSearch = { text in
            if text.count <= 0 {
                return
            }
            
            EMClient.shared().circleManager?.fetchServers(withKeyword: text) { [weak self] servers, error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                    return
                }
                self.searchResult = servers
                self.collectionView.reloadData()
                self.noDataView.isHidden = (self.searchResult?.count ?? 0) > 0
            }
        }
        
        self.searchView.didCancelSearch = { [unowned self] in
            self.collectionView.reloadData()
            self.noDataView.isHidden = true
            UIView.animate(withDuration: 0.3) {
                self.updateCollectionViewContentInset()
            }
        }
        
        self.collectionView.register(UINib(nibName: "SquareCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.loadRecommendServer()
        })
        self.collectionView.mj_header?.alpha = 0
        self.collectionView.mj_header?.isCollectionViewAnimationBug = true
        self.loadRecommendServer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let w = (self.collectionView.bounds.width - 20 * 2 - 12) / 2
            let h = w / 154 * 222
            layout.itemSize = CGSize(width: w, height: h)
        }
        self.updateCollectionViewContentInset()
        self.scrollViewDidScroll(self.collectionView)
    }
    
    private func updateCollectionViewContentInset() {
        if self.searchView.isSearching {
            self.collectionView.contentInset = UIEdgeInsets.zero
        } else {
            let top = self.view.safeAreaInsets.top
            self.collectionView.contentInset = UIEdgeInsets(top: self.topBgImageView.bounds.height - top - 48, left: 0, bottom: 0, right: 0)
        }
    }
    
    private func loadRecommendServer() {
        guard let baseUrl = HTTP.baseUrlWithAppKey, let url = URL(string: "https://\(baseUrl)/circle/server/recommend/list") else {
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        var request = URLRequest(url: url)
        if let token = EMClient.shared().accessUserToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = session.dataTask(with: request) { data, _, error in
            if error != nil {
                DispatchQueue.main.async {
                    Toast.show("请求失败，请稍后再试。", duration: 2)
                }
                return
            }
            let result = self.parseRecommendServers(data: data)
            DispatchQueue.main.async {
                self.recommendServers = result
                self.collectionView.reloadData()
                self.collectionView.mj_header?.endRefreshing()
                self.collectionView.mj_header?.alpha = 0
            }
        }
        task.resume()
    }
    
    private func parseRecommendServers(data: Data?) -> [EMCircleServer]? {
        guard let data = data, let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        guard let code = obj["code"] as? Int, code == 200 else {
            return nil
        }
        guard let list = obj["servers"] as? [[String: Any]] else {
            return nil
        }
        
        var result: [EMCircleServer] = []
        for item in list {
            if let serverId = item["server_id"] as? String, let name = item["name"] as? String, let defaultChannelId = item["default_channel_id"] as? String {
                let server = EMCircleServer(serverId: serverId, name: name, defaultChannelId: defaultChannelId)
                server.owner = item["owner"] as? String
                server.desc = item["description"] as? String
                server.ext = item["custom"] as? String
                server.icon = item["icon_url"] as? String
                var tags: [EMCircleServerTag] = []
                if let tagsList = item["tags"] as? [[String: String]] {
                    for item in tagsList {
                        let tag = EMCircleServerTag()
                        tag.tagId = item["server_tag_id"]
                        tag.name = item["tag_name"]
                        tags.append(tag)
                    }
                }
                server.tags = tags
                result.append(server)
            }
        }
        return result
    }
}

extension SquareViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let top = self.view.safeAreaInsets.top
        var contentOffsetY = -self.collectionView.contentOffset.y
        if contentOffsetY < 0 {
            contentOffsetY = 0
        }
        if contentOffsetY > self.collectionView.contentInset.top {
            self.collectionView.mj_header?.alpha = (contentOffsetY - self.collectionView.contentInset.top) / self.searchView.bounds.height
            contentOffsetY = self.collectionView.contentInset.top
        }
        let searchViewY = contentOffsetY + top
        self.searchView.frame = CGRect(x: 0, y: searchViewY, width: self.view.bounds.width, height: 48)
        
        if !self.searchView.isSearching {
            self.topBgImageView.alpha = contentOffsetY / self.collectionView.contentInset.top
        } else {
            self.topBgImageView.alpha = 0
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        _ = self.searchView.resignFirstResponder()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.searchView.isSearching {
            return self.searchResult?.count ?? 0
        } else {
            return self.recommendServers?.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? SquareCollectionViewCell {
            if self.searchView.isSearching {
                cell.server = self.searchResult?[indexPath.item] as? EMCircleServer
            } else {
                cell.server = self.recommendServers?[indexPath.item]
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var server: EMCircleServer?
        if self.searchView.isSearching {
            server = self.searchResult?[indexPath.item] as? EMCircleServer
        } else {
            server = self.recommendServers?[indexPath.item]
        }
        guard let server = server else {
            return
        }
        EMClient.shared().circleManager?.checkSelfIs(inServer: server.serverId) { isIn, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                if isIn {
                    self.gotoHomePage(serverId: server.serverId)
                } else {
                    let vc = ServerJoinAlertViewController(showType: .joinServer(server: server, joinHandle: { server in
                        self.gotoHomePage(serverId: server.serverId)
                    }))
                    self.present(vc, animated: true)
                }
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
