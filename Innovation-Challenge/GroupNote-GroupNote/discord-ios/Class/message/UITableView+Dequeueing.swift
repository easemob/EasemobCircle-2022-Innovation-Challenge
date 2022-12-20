//
//  UITableView+Dequeueing.swift
//  discord-ios
//
//  Created by zky on 2022/12/18.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
