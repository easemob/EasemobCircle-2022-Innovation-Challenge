//
//  NavigationController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/27.
//

import UIKit

class NavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.navigationBar.backgroundColor = UIColor.clear
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "back_white"), style: .done, target: self, action: #selector(backAction))
    }
    
    @objc private func backAction() {
        self.popViewController(animated: true)
    }
}
