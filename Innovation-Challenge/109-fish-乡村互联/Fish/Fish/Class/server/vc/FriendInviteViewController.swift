//
//  FriendInviteViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/5.
//

import UIKit
import HyphenateChat
import CoreMIDI

class FriendInviteViewController: UIViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    var didInviteHandle: ((_ userId: String, _ complete: @escaping (_ isSuccess: Bool) -> Void) -> Void)?
    
    private var userIds: [String]?
    private var searchResult: [String]?
    private var isSearching = false
    private var invitedUsers: Set<String> = Set()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "邀请好友"
        self.textField.attributedPlaceholder = NSAttributedString(string: "搜索好友", attributes: [
            .foregroundColor: UIColor(white: 1, alpha: 0.75)
        ])
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.separatorColor = UIColor.clear
        self.tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.userIds = EMClient.shared().contactManager?.getContacts()
        if userIds == nil || userIds!.count <= 0 {
            EMClient.shared().contactManager?.getContactsFromServer { [weak self] userIds, error in
                guard let self = self else {
                    return
                }
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    self.userIds = userIds
                    self.tableView.reloadData()
                    if let userIds = userIds, userIds.count > 0 {
                        UserOnlineManager.shared.subscribe(members: userIds) {
                            self.updateVisiableCell()
                        }
                        UserInfoManager.share.queryUserInfo(userIds: userIds) {
                            self.updateVisiableCell()
                        }
                    }
                }
            }
        }
        EMClient.shared().presenceManager?.add(self, delegateQueue: nil)
        self.textField.addTarget(self, action: #selector(textChangeAction(textField:)), for: .editingChanged)
    }
    
    private func updateVisiableCell() {
        for cell in self.tableView.visibleCells {
            if let cell = cell as? ContactsTableViewCell, let userId = cell.userId {
                cell.online = UserOnlineManager.shared.checkIsOnline(userId: userId)
                cell.userInfo = UserInfoManager.share.userInfo(userId: userId)
            }
        }
    }
    
    @objc private func textChangeAction(textField: UITextField) {
        self.search(keyword: textField.text)
    }
    
    private func search(keyword: String?) {
        if let keyword = keyword, keyword.count > 0 {
            self.isSearching = true
            if let userIds = self.userIds {
                var result: [String] = []
                for i in userIds {
                    if i.contains(keyword) {
                        result.append(i)
                    } else {
                        if let userInfo = UserInfoManager.share.userInfo(userId: i) {
                            if userInfo.nickname?.contains(keyword) ?? false {
                                result.append(i)
                            }
                        }
                    }
                }
                self.searchResult = result
            }
        } else {
            self.isSearching = false
            self.searchResult = nil
        }
        self.tableView.reloadData()
    }
}

extension FriendInviteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isSearching {
            return self.searchResult?.count ?? 0
        } else {
            return self.userIds?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ContactsTableViewCell {
            var userId: String?
            if self.isSearching {
                userId = self.searchResult?[indexPath.row]
            } else {
                userId = self.userIds?[indexPath.row]
            }
            cell.userId = userId
            if let userId = userId, userId.count > 0 {
                cell.userInfo = UserInfoManager.share.userInfo(userId: userId)
                cell.online = UserOnlineManager.shared.checkIsOnline(userId: userId)
                cell.showType = .invite(isInvited: self.invitedUsers.contains(userId), handle: { [weak self] in
                    self?.invitedUsers.insert(userId)
                    self?.didInviteHandle?(userId) { _ in
                        
                    }
                    self?.tableView.reloadRows(at: [indexPath], with: .none)
                })
            }
        }
        return cell
    }
}

extension FriendInviteViewController: EMPresenceManagerDelegate {
    func presenceStatusDidChanged(_ presences: [EMPresence]) {
        self.updateVisiableCell()
    }
}
