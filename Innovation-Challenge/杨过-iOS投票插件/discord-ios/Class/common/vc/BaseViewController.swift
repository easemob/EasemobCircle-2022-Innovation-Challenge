//
//  BaseViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/27.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var imageView: UIImageView = UIImageView()
    private var titleView: UIView?
    private var titleLabel: UILabel?
    private var subtitleLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var titleViewLeftInset: CGFloat = 0 {
        didSet {
            self.updateTitleViewLayout()
        }
    }
    var titleViewRightInset: CGFloat = 48 {
        didSet {
            self.updateTitleViewLayout()
        }
    }
    
    var titleLeftImageName: String? {
        didSet {
            self.createTitleView()
            if let imageName = titleLeftImageName {
                self.imageView.image = UIImage(named: imageName)
            } else {
                self.imageView.image = nil
            }
            self.updateTitleViewLayout()
        }
    }
    
    override var title: String? {
        didSet {
            self.createTitleView()
            self.titleLabel?.text = title
            self.updateTitleViewLayout()
        }
    }
    
    var subtitle: String? {
        didSet {
            self.createTitleView()
            self.subtitleLabel?.text = subtitle
            self.updateTitleViewLayout()
        }
    }
    
    private func createTitleView() {
        if self.titleView == nil {
            self.titleView = UIView()
            self.titleView!.backgroundColor = UIColor.clear
            self.titleLabel = UILabel()
            self.titleLabel?.textColor = UIColor.white
            self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            self.titleView!.addSubview(self.titleLabel!)
            self.navigationItem.titleView = self.titleView
            self.subtitleLabel = UILabel()
            self.subtitleLabel?.font = UIFont.systemFont(ofSize: 10)
            self.subtitleLabel?.textColor = UIColor(named: ColorName_BDBDBD)
            self.titleView!.addSubview(self.subtitleLabel!)
            self.titleView?.addSubview(self.imageView)
        }
    }
    
    private func updateTitleViewLayout() {
        if let navigationBar = self.navigationController?.navigationBar {
            self.titleView!.frame = CGRect(x: self.titleViewLeftInset, y: 0, width: navigationBar.frame.width - self.titleViewLeftInset - self.titleViewRightInset, height: navigationBar.frame.height)
            self.imageView.frame = CGRect(x: 0, y: (navigationBar.frame.height - 32) / 2, width: 32, height: 32)
            let x: CGFloat = self.imageView.image == nil ? 0 : 40
            let w: CGFloat = self.titleView!.bounds.width - x
            if self.subtitle == nil {
                self.titleLabel!.frame = CGRect(x: x, y: 0, width: w, height: self.titleView!.bounds.height)
            } else {
                self.titleLabel!.frame = CGRect(x: x, y: 6, width: w, height: 16)
                self.subtitleLabel?.frame = CGRect(x: x, y: 26, width: w, height: 12)
            }
        }
    }
}
