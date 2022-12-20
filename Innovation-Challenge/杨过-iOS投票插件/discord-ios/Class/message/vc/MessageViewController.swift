//
//  MessageViewController.swift
//  circle-ios
//
//  Created by 冯钊 on 2022/6/17.
//

import UIKit
import HyphenateChat

class MessageViewController: UIViewController {

    @IBOutlet private weak var serverListView: MessageServerListView!
    @IBOutlet private weak var rightView: UIView!
    
    private let conversationVC = ConversationViewController()
    private var serverVC: MessageServerViewController?
    
    private var selectedType: MessageServerListView.SelectType?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addChild(self.conversationVC)
        self.selectedTypeDidChange(type: self.serverListView.selectType)
        self.serverListView.didSelectedItem = { [weak self] (type) in
            self?.selectedTypeDidChange(type: type)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.conversationVC.view.frame = self.rightView.bounds
        self.serverVC?.view.frame = self.rightView.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func selectedTypeDidChange(type: MessageServerListView.SelectType) {
        if let selectType = self.selectedType, selectType == type {
            return
        }
        switch type {
        case .conversation:
            self.serverVC?.view.removeFromSuperview()
            self.rightView.addSubview(self.conversationVC.view)
        case .add:
            let vc = ServerCreateViewController()
            self.navigationController?.pushViewController(vc, animated: true)
            return
        case .serverItem(serverId: let serverId):
            if let serverVC = self.serverVC {
                serverVC.serverId = serverId
            } else {
                self.serverVC = MessageServerViewController(serverId: serverId)
                self.addChild(self.serverVC!)
            }
            self.conversationVC.view.removeFromSuperview()
            self.rightView.addSubview(self.serverVC!.view)
        }
        self.selectedType = type
    }
}
