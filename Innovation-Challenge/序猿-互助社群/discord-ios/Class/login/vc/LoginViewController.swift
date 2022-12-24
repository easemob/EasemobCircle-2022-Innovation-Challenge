//
//  LoginViewController.swift
//  circle-ios
//
//  Created by 冯钊 on 2022/6/17.
//

import UIKit
import HyphenateChat

class LoginViewController: UIViewController {
    
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var radioboxButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var loadingImageView: UIImageView!
    let gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUsernameTextField()
        self.radioboxButton.setImage(UIImage(named: "login_radiobox_selected"), for: .selected)
        self.loginButton.isEnabled = false
        
        self.gradientLayer.colors = [
            UIColor(red: 0.008, green: 0.827, blue: 0.784, alpha: 1).cgColor,
            UIColor(red: 0.055, green: 0.808, blue: 0.078, alpha: 1).cgColor
        ]
        self.gradientLayer.locations = [0, 1]
        self.gradientLayer.startPoint = CGPoint(x: 0.25, y: 0.5)
        self.gradientLayer.endPoint = CGPoint(x: 0.75, y: 0.5)
        self.gradientLayer.cornerRadius = 24
        self.gradientLayer.isHidden = true
        self.loginButton.layer.insertSublayer(self.gradientLayer, at: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.gradientLayer.frame = self.loginButton.bounds
    }
    
    @IBAction func loginButtonClick(_ sender: UIButton) {
        guard self.radioboxButton.isSelected else {
            let vc = UIAlertController(title: "提示", message: "请先阅读并同意服务条款与隐私协议", preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(vc, animated: true)
            return
        }
        self.usernameTextField.resignFirstResponder()
        guard let username = self.usernameTextField.text, username.count > 0 else {
            Toast.show("手机号不能为空", duration: 2)
            return
        }
        let phoneRegex = "1[\\d]{10}"
        let regex = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        if !regex.evaluate(with: username) {
            Toast.show("手机号格式错误", duration: 2)
            return
        }
        self.login(username: username, password: "1")
    }
    
    @IBAction func radioboxAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc func clearAction() {
        self.usernameTextField.text = nil
        self.loginButton.isEnabled = false
        self.gradientLayer.isHidden = true
        self.loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
        self.usernameTextField.rightView?.isHidden = true
    }
    
    private func login(username: String, password: String) {
        self.beginLoginAnimation()
        EMClient.shared().login(withUsername: username, password: password) { _, error in
            if let e = error {
                if e.code == .userNotFound {
                    self.register(username: username, password: password)
                } else {
                    Toast.show(e.errorDescription, duration: 2)
                    self.endLoginAnimation()
                }
            } else {
                (UIApplication.shared.delegate as? AppDelegate)?.switchToMain()
                self.endLoginAnimation()
                UserInfoManager.share.queryUserInfo(userId: username, loadCache: false) { userInfo, _ in
                    if let userInfo = userInfo {
                        NotificationCenter.default.post(name: EMCurrentUserInfoUpdate, object: userInfo)
                    }
                }
            }
        }
    }
    
    private func register(username: String, password: String) {
        EMClient.shared().register(withUsername: username, password: password) { _, error in
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
                self.endLoginAnimation()
            } else {
                self.login(username: username, password: password)
            }
        }
    }
    
    private func setupUsernameTextField() {
        self.usernameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        self.usernameTextField.leftViewMode = .always
        self.usernameTextField.attributedPlaceholder = NSAttributedString(string: "请输入您的手机号", attributes: [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor(red: 0.592, green: 0.592, blue: 0.592, alpha: 1)
        ])
        
        let clearButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        clearButton.setImage(UIImage(named: "login_username_clear"), for: .normal)
        clearButton.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        let rightView = UIView(frame: CGRect(x: 0, y: 0, width: clearButton.frame.height + 14, height: clearButton.frame.height))
        rightView.addSubview(clearButton)
        self.usernameTextField.rightView = rightView
        self.usernameTextField.rightView?.isHidden = true
        self.usernameTextField.rightViewMode = .always
        self.usernameTextField.addTarget(self, action: #selector(editingChangedAction), for: .editingChanged)
    }
    
    @objc private func editingChangedAction() {
        if let text = self.usernameTextField.text, text.count > 0 {
            self.loginButton.isEnabled = true
            self.gradientLayer.isHidden = false
            self.loginButton.setTitleColor(UIColor.white, for: .normal)
            self.usernameTextField.rightView?.isHidden = false
        } else {
            self.loginButton.isEnabled = false
            self.gradientLayer.isHidden = true
            self.loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
            self.usernameTextField.rightView?.isHidden = true
        }
    }
    
    private func beginLoginAnimation() {
        self.loadingImageView.isHidden = false
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = CGFloat.pi * 2
        animation.duration = 1
        animation.repeatCount = Float.infinity
        self.loadingImageView.layer.add(animation, forKey: "load")
        self.loginButton.setTitle(nil, for: .normal)
        self.loginButton.isEnabled = false
    }
    
    private func endLoginAnimation() {
        self.loadingImageView.isHidden = true
        self.loadingImageView.layer.removeAllAnimations()
        self.loginButton.setTitle("登录", for: .normal)
        self.loginButton.isEnabled = true
    }
    
    @IBAction func serviceAction() {
        if let url = URL(string: "http://www.easemob.com/protocol") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func privateAction() {
        if let url = URL(string: "http://www.easemob.com/agreement") {
            UIApplication.shared.open(url)
        }
    }
}
