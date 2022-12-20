//
//  ToastView.swift
//  circle-ios
//
//  Created by 冯钊 on 2022/6/20.
//

import UIKit

class Toast {
    public class func show(_ text: String, duration: TimeInterval) {
        guard let keyWindow = UIApplication.shared.keyWindow else {
            return
        }
        let label = UILabel()
        let attrStr = NSAttributedString(string: text, attributes: [
            .font: label.font!
        ])
        let maxWidth = keyWindow.frame.width * 0.8 - 39 * 2
        let size = attrStr.boundingRect(with: CGSize(width: maxWidth, height: 10000), options: .usesFontLeading, context: nil).size
        let x = (keyWindow.frame.width - size.width) / 2 - 39
        let y = keyWindow.frame.height - 22 * 2 - size.height - 110
        let w = 39 * 2 + size.width
        let h = 22 * 2 + size.height
        label.frame = CGRect(x: x, y: y, width: w, height: h)
        label.text = text
        label.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        keyWindow.addSubview(label)
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            label.removeFromSuperview()
        }
    }
}
