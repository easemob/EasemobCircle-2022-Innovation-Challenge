//
//  BubbleMenuView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/30.
//

import UIKit

class BubbleMenuView: UIView {

    private let contentView = UIView()
    
    private var menuItem: [(UIImage, String, () -> Void)] = []
    private let baseView: UIView
    
    class BubbleMenuItem: UIButton {
        override func layoutSubviews() {
            super.layoutSubviews()
            let y = (self.bounds.height - 24) / 2
            self.imageView?.frame = CGRect(x: 6, y: y, width: 24, height: 24)
            self.titleLabel?.frame = CGRect(x: 34, y: 0, width: self.bounds.width - 34, height: self.bounds.height)
        }
    }
    
    init(baseView: UIView) {
        self.baseView = baseView
        super.init(frame: CGRect.zero)
        self.contentView.backgroundColor = UIColor.white
        self.contentView.layer.cornerRadius = 4
        self.addSubview(self.contentView)
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        self.addGestureRecognizer(tapGes)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let window = UIApplication.shared.keyWindow!
        let baseViewFrameInWindow = self.baseView.superview?.convert(self.baseView.frame, to: window)
        let w = 105.0
        let h = CGFloat(self.menuItem.count * 44)
        var x = baseViewFrameInWindow!.midX - 52
        let y = baseViewFrameInWindow!.maxY + 8
        if x + w > window.bounds.maxX {
            x = window.bounds.maxX - 8 - w
        }
        self.contentView.frame = CGRect(x: x, y: y, width: w, height: h)
    }

    public func addMenuItem(image: UIImage, title: String, handle: @escaping () -> Void) {
        self.menuItem.append((image, title, handle))
    }
    
    public func show() {
        for i in 0..<self.menuItem.count {
            let btn = BubbleMenuView.BubbleMenuItem(type: .custom)
            btn.setImage(self.menuItem[i].0, for: .normal)
            btn.setTitle(self.menuItem[i].1, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.setTitleColor(UIColor.black, for: .normal)
            btn.frame = CGRect(x: 0, y: i * 44, width: 104, height: 44)
            btn.addTarget(self, action: #selector(clickAction(_:)), for: .touchUpInside)
            btn.tag = i
            self.contentView.addSubview(btn)
        }
        let window = UIApplication.shared.keyWindow!
        self.frame = window.bounds
        window.addSubview(self)
    }
    
    @objc private func clickAction(_ sender: UIButton) {
        self.menuItem[sender.tag].2()
        self.removeFromSuperview()
    }
    
    @objc private func tapAction() {
        self.removeFromSuperview()
    }
}
