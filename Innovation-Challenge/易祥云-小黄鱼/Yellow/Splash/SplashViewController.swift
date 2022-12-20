//
//  RootViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/25.
//

import UIKit
import HyphenateChat
import LeanCloud

class SplashViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var retryButton: UIButton!
    
    private var error: Error? {
        didSet {
            retryButton.isHidden = error == nil
            if error != nil {
                debugPrint(error!.localizedDescription)
            }
        }
    }
    
    private var needRegister: Bool {
        LCApplication.default.currentUser?.username == nil
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        modalPresentationStyle = .custom
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        NotificationCenter.default.addObserver(forName: .ownUserInfoUpdated, object: nil, queue: .main) {[weak self] _ in
            self?.gotoMainVc()
        }
        
        check()
    }
    
    private func check() {
        Task {
            do {
                if needRegister {
                    try await register()
                }
            } catch {
                self.error = error
                return
            }
            
            if needConfirmUserInfo() {
                performSegue(withIdentifier: "showConfirmVC", sender: nil)
                return
            }
            
            self.gotoMainVc()
        }
    }
    
    private func gotoMainVc() {
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "mainVc") else {
            fatalError()
        }
        
        // 打开app 就开始广播自己
        NearbyPoint.instance.start()
        
        UIView.animate(withDuration: 0.5, animations: { [unowned self] in
            self.imageView.transform = .init(scaleX: 0.5, y: 0.5)
            self.imageView.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: self.imageView.frame.size)
            self.imageView.alpha = 0.0
        }) { [weak self] _ in
            self?.navigationController?.setViewControllers([vc], animated: false)
        }
    }
    
    
    @IBAction func onTapRetryButton(_ sender: UIButton) {
        check()
    }
}
