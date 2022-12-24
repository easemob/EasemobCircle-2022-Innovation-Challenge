//
//  ChannelCreateViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/30.
//

import UIKit
import HyphenateChat
import PKHUD

class ChannelCreateViewController: UIViewController {

    enum ShowType {
        case create(serverId: String)
        case update(serverId: String, channelId: String)
    }
    
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var descTextView: UITextView!
    @IBOutlet private weak var descPlaceholderLabel: UILabel!
    @IBOutlet private weak var nameCountLabel: UILabel!
    @IBOutlet private weak var descCountLabel: UILabel!
    @IBOutlet private weak var privateSwitch: UISwitch!
    
    var createButton: UIButton!
    
    private let showType: ShowType
    
    init(showType: ShowType) {
        self.showType = showType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createButton = UIButton()
        switch self.showType {
        case .create(serverId: _):
            self.title = "新建频道"
            self.createButton.setTitle("创建", for: .normal)
        case .update(serverId: let serverId, channelId: let channelId):
            self.title = "编辑频道"
            self.createButton.setTitle("保存", for: .normal)
            self.privateSwitch.alpha = 0.5
            self.privateSwitch.isEnabled = false
            EMClient.shared().circleManager?.fetchChannelDetail(serverId, channelId: channelId) { channel, error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    self.nameTextField.text = channel?.name
                    self.descTextView.text = channel?.desc
                    self.privateSwitch.isOn = channel?.type == .private
                    self.descPlaceholderLabel.isHidden = channel?.desc?.count ?? 0 > 0
                }
            }
        }
        self.createButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.createButton.setTitleColor(UIColor(named: ColorName_979797), for: .disabled)
        self.createButton.setTitleColor(UIColor(named: ColorName_27AE60), for: .normal)
        self.createButton.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createButton)
        switch self.showType {
        case .create:
            self.createButton.isEnabled = false
        case .update:
            self.createButton.isEnabled = true
        }
        
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "必填项", attributes: [
            .foregroundColor: UIColor(named: ColorName_A7A9AC) ?? UIColor.gray
        ])
        self.descTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        self.descTextView.delegate = self
        self.descTextView.textContainerInset = UIEdgeInsets.zero
        
        self.nameTextField.setMaxLength(16) { [unowned self] length in
            self.nameCountLabel.text = "\(length)/16"
            self.createButton.isEnabled = length > 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc private func createAction() {
        guard let name = self.nameTextField.text, name.count > 0 else {
            return
        }
        switch self.showType {
        case .create(serverId: let serverId):
            let channelAttr = EMCircleChannelAttribute()
            channelAttr.name = self.nameTextField.text
            channelAttr.desc = self.descTextView.text
            HUD.show(.progress, onView: self.view)
            EMClient.shared().circleManager?.createChannel(serverId, attribute: channelAttr, type: self.privateSwitch.isOn ? .private : .public) { channel, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    Toast.show("创建成功", duration: 2)
                    NotificationCenter.default.post(name: EMCircleDidCreateChannel, object: channel)
                    self.dismiss(animated: true) {
                        guard let serverId = channel?.serverId, let channelId = channel?.channelId, let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? UITabBarController else {
                            return
                        }
                        let vc = ChatViewController(chatType: .channel(serverId: serverId, channelId: channelId))
                        tabBarController.dismiss(animated: true) {
                            (tabBarController.selectedViewController as? UINavigationController)?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        case .update(serverId: let serverId, channelId: let channelId):
            let channelAttr = EMCircleChannelAttribute()
            channelAttr.name = self.nameTextField.text
            channelAttr.desc = self.descTextView.text
            HUD.show(.progress, onView: self.view)
            EMClient.shared().circleManager?.updateChannel(serverId, channelId: channelId, attribute: channelAttr) { channel, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    Toast.show("修改成功", duration: 2)
                    self.navigationController?.popViewController(animated: true)
                    NotificationCenter.default.post(name: EMCircleDidUpdateChannel, object: channel)
                }
            }
        }
    }
}

extension ChannelCreateViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var count = self.descTextView.text.count
        self.descPlaceholderLabel.isHidden = count > 0
        if count > 120 {
            count = 120
            textView.text = textView.text.subsring(to: 120)
        }
        self.descCountLabel.text = "\(count)/120"
    }
}
