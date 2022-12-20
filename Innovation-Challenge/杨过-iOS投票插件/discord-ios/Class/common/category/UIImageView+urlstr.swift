//
//  UIImageView+urlstr.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/8.
//

import Kingfisher

extension UIImageView {
    @discardableResult
    func setImage(withUrl url: String?, placeholder: String? = nil) -> DownloadTask? {
        var image: UIImage?
        if let placeholder = placeholder {
            image = UIImage(named: placeholder)
        }
        if let urlStr = url, let url = URL(string: urlStr) {
            return self.kf.setImage(with: url, placeholder: image, options: nil, completionHandler: nil)
        } else {
            self.image = image
        }
        return nil
    }
}
