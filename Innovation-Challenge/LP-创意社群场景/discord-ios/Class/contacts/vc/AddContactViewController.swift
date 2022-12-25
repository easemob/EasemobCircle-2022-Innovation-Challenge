//
//  AddContactViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/27.
//

import UIKit
import HyphenateChat

class AddContactViewController: BaseViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var noDataView: UIImageView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var dataList: [EMUserInfo]?
    
    private var contactSet = Set<String>()
    private var addingSet = Set<String>()
    private let userOnlineStateCache = UserOnlineStateCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "添加好友"
        self.textField.attributedPlaceholder = NSAttributedString(string: "输入环信ID添加好友", attributes: [
            .foregroundColor: UIColor(white: 1, alpha: 0.74)
        ])
        self.textField.becomeFirstResponder()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ContactsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        if let contacts = EMClient.shared().contactManager?.getContacts() {
            for contact in contacts {
                self.contactSet.insert(contact)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func cleanAction(_ sender: Any) {
        self.textField.text = ""
    }
}

extension AddContactViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ContactsTableViewCell {
            let userInfo = self.dataList?[indexPath.row]
            cell.userInfo = userInfo
            if let userId = userInfo?.userId {
                cell.online = self.userOnlineStateCache.getUserStatus(userId) == .online
            }
            if let userId = userInfo?.userId, userId.count > 0 {
                if self.contactSet.contains(userId) {
                    cell.showType = .added
                } else if self.addingSet.contains(userId) {
                    cell.showType = .adding
                } else {
                    cell.showType = .add(addHandle: {
                        self.textField.resignFirstResponder()
                        if userId == EMClient.shared().currentUsername {
                            Toast.show("不支持添加自己", duration: 2)
                            return
                        }
                        EMClient.shared().contactManager?.addContact(userId, message: nil) { _, error in
                            if let error = error {
                                DispatchQueue.main.async {
                                    Toast.show(error.errorDescription, duration: 3)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.addingSet.insert(userId)
                                    self.tableView.reloadData()
                                    Toast.show("已发送好友申请", duration: 3)
                                }
                            }
                        }
                    })
                }
            }
        }
        return cell
    }
    
    @IBAction func tableViewTapAction(_ sender: UITapGestureRecognizer) {
        self.textField.resignFirstResponder()
    }
}

extension AddContactViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.textField.resignFirstResponder()
    }
}

extension AddContactViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let userId = self.textField.text, userId.count > 0 else {
            return false
        }
        EMClient.shared().userInfoManager?.fetchUserInfo(byId: [userId]) { [weak self] data, error in
            if let error = error {
                DispatchQueue.main.async {
                    Toast.show(error.errorDescription, duration: 3)
                }
            } else if let data = data {
                DispatchQueue.main.async {
                    self?.dataList = Array(data.values) as? [EMUserInfo]
                    self?.tableView.reloadData()
                    self?.noDataView.isHidden = true
                    var userIds: [String] = []
                    for item in data {
                        if let item = item.value as? EMUserInfo, let userId = item.userId {
                            userIds.append(userId)
                        }
                    }
                    self?.userOnlineStateCache.refresh(members: userIds) { [weak self] in
                        self?.tableView.reloadData()
                    }
                }
            }
        }
        return true
    }
}
