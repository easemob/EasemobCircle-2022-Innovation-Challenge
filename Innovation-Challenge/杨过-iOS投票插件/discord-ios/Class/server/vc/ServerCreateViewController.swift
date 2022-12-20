//
//  ServerCreateViewController.swift
//  circle-ios
//
//  Created by 冯钊 on 2022/6/17.
//

import UIKit
import HyphenateChat
import PhotosUI
import TZImagePickerController
import PKHUD

class ServerCreateViewController: BaseViewController {

    var createButton: UIButton!
    @IBOutlet private weak var iconButton: ServerCreateIconButton!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var descTextView: UITextView!
    @IBOutlet private weak var descPlaceholderLabel: UILabel!
    @IBOutlet private weak var nameCountLabel: UILabel!
    @IBOutlet private weak var descCountLabel: UILabel!
    
    var uploadImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "创建社区"

        self.createButton = UIButton()
        self.createButton.setTitle("创建", for: .normal)
        self.createButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        self.createButton.setTitleColor(UIColor(named: ColorName_979797), for: .disabled)
        self.createButton.setTitleColor(UIColor(named: ColorName_27AE60), for: .normal)
        self.createButton.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createButton)
        self.createButton.isEnabled = false
        
        self.iconButton.showType = .create
        self.nameTextField.attributedPlaceholder = NSAttributedString(string: "必填项", attributes: [
            .foregroundColor: UIColor(named: ColorName_A7A9AC) ?? UIColor.gray
        ])
        self.clearButton.isHidden = true
        self.descTextView.delegate = self
        self.descTextView.textContainerInset = UIEdgeInsets.zero
        self.descTextView.contentInset = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        
        self.nameTextField.setMaxLength(16) { [unowned self] length in
            self.clearButton.isHidden = length <= 0
            self.nameCountLabel.text = "\(length)/16"
            self.createButton.isEnabled = length > 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func createAction() {
        guard let name = self.nameTextField.text else {
            return
        }
        
        if let image = self.uploadImage {
            HUD.show(.progress, onView: self.view)
            HTTP.uploadImage(image: image) { path, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.localizedDescription, duration: 2)
                } else if let path = path {
                    self.createServer(name: name, icon: path)
                }
            }
        } else {
            self.createServer(name: name, icon: "")
        }
    }
    
    @IBAction func iconAction() {
        PHPhotoLibrary.request {
            if let vc = TZImagePickerController(maxImagesCount: 1, delegate: nil) {
                vc.allowPickingOriginalPhoto = false
                vc.allowPickingVideo = false
                vc.allowCrop = true
                vc.photoWidth = 200
                vc.didFinishPickingPhotosHandle = { images, _, _ in
                    if let image = images?.first {
                        UIGraphicsBeginImageContext(CGSize(width: 200, height: 200))
                        image.draw(in: CGRect(x: 0, y: 0, width: 200, height: 200))
                        let newImage = UIGraphicsGetImageFromCurrentImageContext()
                        UIGraphicsEndImageContext()
                        
                        self.iconButton.showType = .update
                        self.iconButton.setBackgroundImage(newImage, for: .normal)
                        self.uploadImage = newImage
                    }
                }
                self.present(vc, animated: true)
            }
        }
    }
    
    @IBAction func clearAction() {
        self.nameTextField.text = nil
        self.createButton.isEnabled = false
        self.clearButton.isHidden = true
        self.nameCountLabel.text = "0/16"
    }
    
    private func createServer(name: String, icon: String) {
        let attribute = EMCircleServerAttribute()
        attribute.name = name
        attribute.icon = icon
        attribute.desc = self.descTextView.text
        attribute.ext = ""
        HUD.show(.progress, onView: self.view)
        EMClient.shared().circleManager?.createServer(attribute) { server, error in
            HUD.hide()
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else if let server = server {
                Toast.show("创建成功", duration: 2)
                NotificationCenter.default.post(name: EMCircleDidCreateServer, object: server)
                let vc = ChatViewController(chatType: .channel(serverId: server.serverId, channelId: server.defaultChannelId))
                self.navigationController?.pushViewController(vc, animated: true)
                let vcs = self.navigationController?.viewControllers
                if var vcs = vcs, vcs.count > 2 {
                    vcs.remove(at: vcs.count - 2)
                    self.navigationController?.viewControllers = vcs
                }
            }
        }
    }
}

extension ServerCreateViewController: UITextViewDelegate {
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
