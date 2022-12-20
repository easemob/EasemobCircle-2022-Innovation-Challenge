//
//  ThreadEditViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/12.
//

import UIKit
import PKHUD
import HyphenateChat

class ThreadEditViewController: UIViewController {

    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var nameLengthLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    private let saveButton = UIButton(type: .custom)
    
    private let threadId: String
    
    init(threadId: String) {
        self.threadId = threadId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "编辑子区"
        self.saveButton.setTitle("保存", for: .normal)
        self.saveButton.setTitleColor(UIColor(named: ColorName_979797), for: .disabled)
        self.saveButton.setTitleColor(UIColor(named: ColorName_27AE60), for: .normal)
        self.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.saveButton.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.saveButton)
        self.clearButton.isHidden = true
        
        self.nameTextField.setMaxLength(16) { [unowned self] length in
            self.nameLengthLabel.text = "\(length)/16"
            self.clearButton.isHidden = length <= 0
            self.saveButton.isEnabled = length > 0
        }
        
        HUD.show(.progress, onView: self.view)
        EMClient.shared().threadManager?.getChatThread(fromSever: self.threadId, completion: { thread, error in
            HUD.hide()
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            }
            self.nameTextField.text = thread?.threadName
            self.nameTextField.becomeFirstResponder()
        })
    }
    
    private func updateNameLength() {
        self.nameLengthLabel.text = "\(self.nameTextField.text?.count ?? 0)/16"
    }
    
    @objc private func saveAction() {
        if let name = self.nameTextField.text {
            HUD.show(.progress, onView: self.view)
            EMClient.shared().threadManager?.updateChatThreadName(name, threadId: self.threadId) { error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else {
                    Toast.show("修改成功", duration: 2)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func nameClearAction() {
        self.nameTextField.text = nil
        self.clearButton.isHidden = true
        self.saveButton.isEnabled = false
        self.updateNameLength()
    }
}
