//
//  MessageServerListLayout.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/9/5.
//

import UIKit

class MessageServerListLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let list = super.layoutAttributesForElements(in: rect)
        if let item = list?.first, item.indexPath.item == 0 {
            let frame = item.frame
            let y = self.collectionView?.contentOffset.y ?? 0
            item.frame = CGRect(x: frame.minX, y: y, width: frame.width, height: frame.height)
            item.zIndex = 1
        }
        return list
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
