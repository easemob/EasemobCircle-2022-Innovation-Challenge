//
//  MeSettingViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/27.
//

import UIKit
import HyphenateChat
import TZImagePickerController
import Photos
import PKHUD

class MeSettingViewController: BaseViewController {

    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    
    private lazy var alertVc: UIAlertController = {
        let alertVC = UIAlertController(title: "修改昵称", message: nil, preferredStyle: .alert)
        alertVC.addTextField { textField in
            textField.placeholder = "昵称"
            textField.addTarget(self, action: #selector(self.onTextChangeAction(textField:)), for: .editingChanged)
        }
        alertVC.addAction(UIAlertAction(title: "取消", style: .cancel))
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: { [unowned self] _ in
            guard let text = alertVC.textFields?.first?.text, text.count > 0 else {
                Toast.show("请输入用户名", duration: 2)
                return
            }
            EMClient.shared().userInfoManager?.updateOwnUserInfo(text, with: .nickName) { userInfo, error in
                DispatchQueue.main.async {
                    if let error = error {
                        Toast.show(error.errorDescription, duration: 2)
                    } else if let userInfo = userInfo {
                        UserInfoManager.share.storeUserInfo(userInfos: [userInfo])
                        self.nameLabel.text = userInfo.showname
                        Toast.show("修改昵称成功", duration: 2)
                        NotificationCenter.default.post(name: EMCurrentUserInfoUpdate, object: userInfo)
                    }
                }
            }
        }))
        return alertVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        
        if let userId = EMClient.shared().currentUsername {
            self.nameLabel.text = userId
            UserInfoManager.share.queryUserInfo(userId: userId, loadCache: false) { userInfo, error in
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                    return
                } else {
                    self.iconImageView.setImage(withUrl: userInfo?.avatarUrl, placeholder: "head_placeholder")
                    self.nameLabel.text = userInfo?.showname
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func iconAction() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "从手机相册选择", style: .default, handler: { _ in
            self.showPhotoLibrary()
        }))
        vc.addAction(UIAlertAction(title: "拍照", style: .default, handler: { _ in
            let vc = UIImagePickerController()
            vc.sourceType = .camera
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        vc.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(vc, animated: true)
    }
    
    @IBAction func nameAction() {
        self.alertVc.actions.last?.isEnabled = false
        self.alertVc.textFields?.first?.text = nil
        self.present(self.alertVc, animated: true)
    }
    
    @objc private func onTextChangeAction(textField: UITextField) {
        self.alertVc.actions.last?.isEnabled = textField.text?.count ?? 0 > 0
    }
    
    private func showPhotoLibrary() {
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
                        
                        if let newImage = newImage {
                            self.updateUserAvatar(image: newImage)
                        }
                    }
                }
                self.present(vc, animated: true)
            }
        }
    }
    
    private func updateUserAvatar(image: UIImage) {
        self.iconImageView.image = image
        HUD.show(.progress, onView: self.view)
        HTTP.uploadImage(image: image) { path, error in
            if let error = error {
                HUD.hide()
                Toast.show(error.localizedDescription, duration: 2)
            } else if let path = path {
                EMClient.shared().userInfoManager?.updateOwnUserInfo(path, with: .avatarURL) { userInfo, error in
                    DispatchQueue.main.async {
                        HUD.hide()
                        if let error = error {
                            Toast.show(error.errorDescription, duration: 2)
                        } else if let userInfo = userInfo {
                            UserInfoManager.share.storeUserInfo(userInfos: [userInfo])
                            NotificationCenter.default.post(name: EMCurrentUserInfoUpdate, object: userInfo)
                        }
                    }
                }
            } else {
                HUD.hide()
            }
        }
    }
}

extension MeSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            let height = 200 / (image.size.width / image.size.height)
            UIGraphicsBeginImageContext(CGSize(width: 200, height: height))
            image.draw(in: CGRect(x: 0, y: 0, width: 200, height: height))
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let newImage = newImage {
                self.updateUserAvatar(image: newImage)
            }
        }
        picker.dismiss(animated: true)
    }
}
