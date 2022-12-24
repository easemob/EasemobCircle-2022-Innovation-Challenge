//
//  ChatBottomMenuLayout.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/6.
//

import UIKit

class ChatBottomMenuLayout: UICollectionViewFlowLayout {

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
//            self.hSpace = floor((self.collectionViewBounds.width - (self.itemSize.width * 7) - self.sectionInset.left - self.sectionInset.right) / 6)
            let w = floor((self.collectionViewBounds.width - collectionView.contentInset.left - collectionView.contentInset.right) / 7)
            self.itemSize = CGSize(width: w, height: w)
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
        let row = CGFloat(indexPath.row % 28 / 7)
        let column = CGFloat(indexPath.row % 28 % 7)
        let x = pageIndex * self.collectionViewBounds.width + column * self.itemSize.width + column * hSpace + self.sectionInset.left
        let y = row * self.itemSize.height + row * vSpace + self.sectionInset.top
        layout?.frame = CGRect(x: x, y: y, width: self.itemSize.width, height: self.itemSize.height)
        return layout
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.layouts
    }
    
    override var collectionViewContentSize: CGSize {
        let pageCount = (self.dataCount - 1) / 28 + 1
        return CGSize(width: self.collectionViewBounds.width * CGFloat(pageCount), height: self.collectionViewBounds.height)
    }
}
