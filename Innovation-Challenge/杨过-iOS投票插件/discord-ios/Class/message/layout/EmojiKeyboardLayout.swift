//
//  EmojiKeyboardLayout.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/4.
//

import UIKit

class EmojiKeyboardLayout: UICollectionViewFlowLayout {

    private var layouts: [UICollectionViewLayoutAttributes] = []
    private var hSpace: CGFloat = 0
    private var vSpace: CGFloat = 0
    private var dataCount = 0
    private var collectionViewBounds = CGRect.zero
    
    override func prepare() {
        super.prepare()
        self.layouts.removeAll()
        if let collectionView = self.collectionView {
            self.collectionViewBounds = collectionView.bounds
            self.dataCount = collectionView.numberOfItems(inSection: 0)
            self.hSpace = (self.collectionViewBounds.width - (self.itemSize.width * 7) - self.sectionInset.left - self.sectionInset.right) / 6
            self.vSpace = floor((self.collectionViewBounds.height - (self.itemSize.height * 4) - self.sectionInset.top - self.sectionInset.bottom) / 3)
        }
        for i in 0..<self.dataCount {
            let indexpath = IndexPath(row: i, section: 0)
            if let layout = self.layoutAttributesForItem(at: indexpath) {
                self.layouts.append(layout)
            }
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layout = super.layoutAttributesForItem(at: indexPath)
        let pageIndex = CGFloat(indexPath.row / 28)
        var row = CGFloat(indexPath.row % 28 / 7)
        var column = CGFloat(indexPath.row % 28 % 7)
        if indexPath.row == self.dataCount - 1 {
            row = 3
            column = 6
        }
        let x = pageIndex * self.collectionViewBounds.width + column * self.itemSize.width + column * hSpace + self.sectionInset.left
        let y = row * self.itemSize.height + row * vSpace + self.sectionInset.top
        layout?.frame = CGRect(x: x, y: y, width: self.itemSize.width, height: self.itemSize.height)
        return layout
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layouts
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.collectionViewBounds.width * 2, height: self.collectionViewBounds.height)
    }
}
