//
//  UIViewController+popover.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/2.
//

import UIKit

extension UIViewController {
    @objc private func presentNavigationControllerBackAction() {
        self.presentedViewController?.dismiss(animated: true)
    }
    
    func presentNavigationController(rootViewController: UIViewController) {
        let navVc = NavigationController(rootViewController: rootViewController)
        navVc.modalPresentationStyle = .popover
        navVc.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 16, weight: .bold)
        ]
        rootViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "popview_close_white"), style: .done, target: self, action: #selector(presentNavigationControllerBackAction))
        self.present(navVc, animated: true)
    }
}
