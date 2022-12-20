//
//  ContactsViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import UIKit
import HyphenateChat

class ContactsViewController: UIViewController {

    @IBOutlet private weak var segmentBgCenterXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var segmentView: UIView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var noDataView: UIView!
    @IBOutlet private weak var newRequestView: UIView!
    @IBOutlet private weak var searchView: UIView!
    @IBOutlet private weak var tableViewTopConstraint: NSLayoutConstraint!
    private var segmentSelectedIndex = 0
    
    private var contactList: [String]?
    private var onLineContactList: [String]?
    private var friendRequestList: [String] = []
    private var searchResult: [String]?
    private var isSearching = false
    
    private var needUpdateOnlineList = false
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        EMClient.shared().contactManager?.add(self, delegateQueue: nil)
        EMClient.shared().addMultiDevices(delegate: self, queue: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.textField.attributedPlaceholder = NSAttributedString(string: "搜索好友", attributes: [
            .foregroundColor: UIColor(white: 1, alpha: 0.75)
        ])
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        EMClient.shared().contactManager?.getContactsFromServer { [weak self] userIds, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else if let userIds = userIds, let self = self {
                self.contactList = userIds
                self.tableView.reloadData()
                if userIds.count > 0 {
                    UserOnlineManager.shared.subscribe(members: userIds) {
                        if self.segmentSelectedIndex == 0 {
                            self.updateOnlineList()
                        } else {
                            self.updateVisiableCell()
                            self.needUpdateOnlineList = true
                        }
                    }
                    UserInfoManager.share.queryUserInfo(userIds: userIds) {
                        self.updateVisiableCell()
                    }
                }
            }
            self?.updateNoDataView()
        }
        
        EMClient.shared().presenceManager?.add(self, delegateQueue: nil)
                
        self.newRequestView.isHidden = self.friendRequestList.count <= 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(onRecvUserInfoUpdateNotification(notification:)), name: EMUserInfoUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func addContactAction() {
        let vc = AddContactViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func segmentAction(_ sender: UIButton) {
        self.segmentBgCenterXConstraint.constant = (sender.frame.width + 12) * CGFloat(sender.tag)
        self.newRequestView.isHidden = sender.tag == 2 || self.friendRequestList.count <= 0
        (self.segmentView.viewWithTag(self.segmentSelectedIndex) as? UIButton)?.isSelected = false
        self.segmentSelectedIndex = sender.tag
        (self.segmentView.viewWithTag(self.segmentSelectedIndex) as? UIButton)?.isSelected = true
        
        if self.segmentSelectedIndex == 2 {
            self.tableViewTopConstraint.constant = 0
            self.searchView.isHidden = true
            self.isSearching = false
        } else {
            self.tableViewTopConstraint.constant = 48
            self.searchView.isHidden = false
            if let text = self.textField.text, text.count > 0 {
                self.isSearching = true
            }
        }
        
        UIView.animate(withDuration: 0.15) {
            self.segmentView.layoutIfNeeded()
        }
        
        if self.isSearching {
            self.search(keyword: self.textField.text)
        } else {
            if self.segmentSelectedIndex == 0 && self.needUpdateOnlineList {
                self.updateOnlineList()
            } else {
                self.tableView.reloadData()
            }
        }
        self.updateNoDataView()
    }
    
    private func updateVisiableCell() {
        for cell in self.tableView.visibleCells {
            if let cell = cell as? ContactsTableViewCell, let userId = cell.userId {
                cell.userId = userId
            }
        }
    }
    
    private func updateOnlineList() {
        self.needUpdateOnlineList = false
        var list: [String] = []
        if let contactList = self.contactList {
            for item in contactList where UserOnlineManager.shared.checkIsOnline(userId: item) {
                list.append(item)
            }
        }
        self.onLineContactList = list
        self.tableView.reloadData()
        self.updateNoDataView()
    }
    
    private func updateNoDataView() {
        let list = self.currentShowList(isSearching: self.isSearching)
        self.noDataView.isHidden = (list?.count ?? 0) > 0
    }
    
    private func search(keyword: String?) {
        if let keyword = keyword, keyword.count > 0 {
            self.isSearching = true
            let searchList = self.currentShowList(isSearching: false)
            if let userIds = searchList {
                var result: [String] = []
                for i in userIds {
                    if i.contains(keyword) {
                        result.append(i)
                    } else if let nickName = UserInfoManager.share.userInfo(userId: i)?.nickname, nickName.contains(keyword) {
                        result.append(i)
                    }
                }
                self.searchResult = result
            }
        } else {
            self.isSearching = false
            self.searchResult = nil
        }
        self.tableView.reloadData()
        self.updateNoDataView()
    }
    
    @IBAction private func searchKeywordChangeAction(_ sender: UITextField) {
        self.search(keyword: sender.text)
    }
    
    @objc private func onRecvUserInfoUpdateNotification(notification: Notification) {
        guard let userInfo = notification.object as? EMUserInfo else {
            return
        }
        for cell in self.tableView.visibleCells {
            if let cell = cell as? ContactsTableViewCell, cell.userId == userInfo.userId, let indexPath = self.tableView.indexPath(for: cell) {
                self.tableView.performBatchUpdates {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
                return
            }
        }
    }
    
    deinit {
        EMClient.shared().contactManager?.removeDelegate(self)
        EMClient.shared().presenceManager?.remove(self)
        NotificationCenter.default.removeObserver(self)
    }
}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentShowList(isSearching: self.isSearching)?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ContactsTableViewCell {
            let userId = self.currentShowList(isSearching: self.isSearching)?[indexPath.row]
            cell.userId = userId
            if let userId = userId {
                if self.segmentSelectedIndex == 2 {
                    cell.showType = .inviteCMD(acceptHandle: {
                        EMClient.shared().contactManager?.approveFriendRequest(fromUser: userId) { [weak self] _, error in
                            if let error = error {
                                Toast.show(error.errorDescription, duration: 2)
                            } else {
                                Toast.show("添加好友成功", duration: 2)
                                self?.removeFriendInvite(userId: userId)
                            }
                        }
                    }, refuseHandle: {
                        EMClient.shared().contactManager?.declineFriendRequest(fromUser: userId) { [weak self] _, error in
                            if let error = error {
                                Toast.show(error.errorDescription, duration: 2)
                            } else {
                                Toast.show("拒绝成功", duration: 2)
                                self?.removeFriendInvite(userId: userId)
                            }
                        }
                    })
                } else {
                    cell.showType = .chat(chatHandle: { [unowned self] in
                        let vc = ChatViewController(chatType: .single(userId: userId))
                        self.navigationController?.pushViewController(vc, animated: true)
                    })
                }
            }
        }
        return cell
    }
    
    private func removeFriendInvite(userId: String) {
        if let index = self.friendRequestList.firstIndex(of: userId) {
            self.friendRequestList.remove(at: index)
            if self.friendRequestList.count <= 0 {
                self.newRequestView.isHidden = true
                (UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.tabBar.hiddenBadge(index: 2)
            } else {
                self.newRequestView.isHidden = false
                (UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.tabBar.showBadge(index: 2)
            }
            if self.segmentSelectedIndex == 2 {
                if self.isSearching {
                    self.removeSearchResultUser(userId)
                } else {
                    self.tableView.performBatchUpdates {
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }
        }
    }
    
    private func currentShowList(isSearching: Bool) -> [String]? {
        if isSearching {
            return self.searchResult
        } else if self.segmentSelectedIndex == 2 {
            return self.friendRequestList
        } else if segmentSelectedIndex == 1 {
            return self.contactList
        } else {
            return self.onLineContactList
        }
    }
    
    private func removeSearchResultUser(_ userId: String) {
        if let index = self.searchResult?.firstIndex(of: userId) {
            self.searchResult?.remove(at: index)
            self.tableView.performBatchUpdates {
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        }
    }
    
    private func addContact(userId: String) {
        if let contactList = self.contactList, contactList.contains(userId) {
            return
        }
        var contactList = self.contactList ?? []
        contactList.append(userId)
        self.contactList = contactList
        if !self.isSearching, self.segmentSelectedIndex == 1, let contactList = self.contactList {
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: [IndexPath(row: contactList.count - 1, section: 0)], with: .none)
            }
        }
        UserOnlineManager.shared.subscribe(members: [userId]) {
            self.presenceStatusDidChanged([])
        }
        self.updateNoDataView()
    }
}

extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userId = self.currentShowList(isSearching: self.isSearching)?[indexPath.row] {
            let vc = UserInfoViewController(showType: .other(userId: userId))
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.textField.resignFirstResponder()
    }
}

extension ContactsViewController: EMContactManagerDelegate {
    func friendRequestDidReceive(fromUser aUsername: String, message aMessage: String?) {
        self.friendRequestList.append(aUsername)
        (UIApplication.shared.keyWindow?.rootViewController as? UITabBarController)?.tabBar.showBadge(index: 2)
        if !self.isViewLoaded {
            return
        }
        self.newRequestView.isHidden = false
        if self.segmentSelectedIndex == 2 && !self.isSearching {
            self.tableView.performBatchUpdates {
                self.tableView.insertRows(at: [IndexPath(row: self.friendRequestList.count - 1, section: 0)], with: .none)
            }
        }
        self.updateNoDataView()
    }
    
    func friendshipDidAdd(byUser username: String) {
        if !self.isViewLoaded {
            return
        }
        self.addContact(userId: username)
    }
    
    func friendshipDidRemove(byUser username: String) {
        if !self.isViewLoaded {
            return
        }
        if let index = self.contactList?.firstIndex(of: username) {
            self.contactList?.remove(at: index)
            if self.segmentSelectedIndex == 1 {
                if self.isSearching {
                    self.removeSearchResultUser(username)
                } else {
                    self.tableView.performBatchUpdates {
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }
        } else {
            return
        }
        if let index = self.onLineContactList?.firstIndex(of: username) {
            self.onLineContactList?.remove(at: index)
            if self.segmentSelectedIndex == 0 {
                if self.isSearching {
                    self.removeSearchResultUser(username)
                } else {
                    self.tableView.performBatchUpdates {
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    }
                }
            }
        }
        self.updateNoDataView()
    }
}

extension ContactsViewController: EMPresenceManagerDelegate {
    func presenceStatusDidChanged(_ presences: [EMPresence]) {
        if self.segmentSelectedIndex == 0 {
            self.updateOnlineList()
        } else {
            self.updateVisiableCell()
            self.needUpdateOnlineList = true
        }
    }
}

extension ContactsViewController: EMMultiDevicesDelegate {
    func multiDevicesContactEventDidReceive(_ aEvent: EMMultiDevicesEvent, username aUsername: String, ext aExt: String?) {
        switch aEvent {
        case .contactRemove:
            self.friendshipDidRemove(byUser: aUsername)
        case .contactAccept:
            self.removeFriendInvite(userId: aUsername)
            self.addContact(userId: aUsername)
        case .contactDecline:
            self.removeFriendInvite(userId: aUsername)
        default:
            break
        }
    }
}
