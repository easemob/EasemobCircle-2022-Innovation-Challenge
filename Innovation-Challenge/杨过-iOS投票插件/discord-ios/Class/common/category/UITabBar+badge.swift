//
//  UITabBar+badge.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/18.
//

import Foundation
import UIKit

private var badgeMap: [Int: UIView] = [:]

extension UITabBar {
    func showBadge(index: Int) {
        if let view = badgeMap[index] {
            view.isHidden = false
        } else {
            let bgView = UIView()
            bgView.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
            bgView.backgroundColor = UIColor.black
            bgView.layer.cornerRadius = 6
            let fgView = UIView()
            fgView.frame = CGRect(x: 2, y: 2, width: 8, height: 8)
            fgView.backgroundColor = UIColor(named: ColorName_FF1477)
            fgView.layer.cornerRadius = 4
            bgView.addSubview(fgView)
            badgeMap[index] = bgView
            
            let view = self.subviews[index + 1]
            bgView.center = CGPoint(x: view.frame.midX + 14, y: view.frame.minY + 28)
            self.insertSubview(bgView, at: 999)
        }
    }
    
    func hiddenBadge(index: Int) {
        if let view = badgeMap[index] {
            view.isHidden = true
        }
    }
}
