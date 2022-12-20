//
//  EmojiListView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/4.
//

import UIKit
import SnapKit

class EmojiListView: UIView {
    
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: EmojiKeyboardLayout())
    private let pageControl = UIPageControl()
    
    var didSelectedEmojiHandle: ((_ emoji: String) -> Void)?
    var didClickDeleteHandle: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.selfInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selfInit()
    }
    
    private func selfInit() {
        if let layout = self.collectionView.collectionViewLayout as? EmojiKeyboardLayout {
            layout.sectionInset = UIEdgeInsets(top: 16, left: 7, bottom: 0, right: 7)
            layout.itemSize = CGSize(width: 50, height: 50)
        }
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.isPagingEnabled = true
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "EmojiListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.addSubview(self.collectionView)
        
        self.pageControl.numberOfPages = 2
        self.pageControl.addTarget(self, action: #selector(pageAction), for: .valueChanged)
        self.addSubview(self.pageControl)
        
        self.collectionView.snp.makeConstraints { make in
            make.left.top.right.equalTo(0)
            make.bottom.equalTo(-22)
        }
        self.pageControl.snp.makeConstraints { make in
            make.left.right.equalTo(0)
            make.top.equalTo(self.collectionView.snp.bottom)
            make.bottom.equalTo(-14)
        }
    }
    
    @objc private func pageAction() {
        self.collectionView.contentOffset = CGPoint(x: CGFloat(self.pageControl.currentPage) * self.collectionView.bounds.width, y: 0)
    }
}

extension EmojiListView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 49
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? EmojiListCollectionViewCell {
            let index = indexPath.item - indexPath.item / 27
            if (indexPath.item + 1) % 28 == 0 || indexPath.item == 48 {
                cell.imageName = "emoji_delete"
                cell.imageWidthConstraint.constant = 38
            } else {
                cell.imageName = "ee_\(index + 1)"
                cell.imageWidthConstraint.constant = 32
            }
        }
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.pageControl.currentPage = scrollView.contentOffset.x > scrollView.bounds.width / 2 ? 1 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.row - indexPath.row / 27
        if (indexPath.row + 1) % 28 == 0 || indexPath.row == 48 {
            self.didClickDeleteHandle?()
        } else {
            self.didSelectedEmojiHandle?("ee_\(index + 1)")
        }
    }
}
