//
//  ChatBottomMenuView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/6.
//

import UIKit

protocol ChatBottomMenuViewDelegate: NSObjectProtocol {
    func chatBottomMenuViewDidSelectedReaction(view: ChatBottomMenuView, reaction: String, userInfo: [String: Any]?)
    func chatBottomMenuViewDidSelectedMenuItem(view: ChatBottomMenuView, menuItem: ChatBottomMenuView.MenuItem, userInfo: [String: Any]?)
    func chatBottomMenuViewGetIsAdded(view: ChatBottomMenuView, reaction: String, userInfo: [String: Any]?) -> Bool
}

class ChatBottomMenuView: UIView {

    enum MenuItem {
        case copy
        case thread
        case recall
    }
        
    @IBOutlet weak var mainView: UIView!
    @IBOutlet private weak var emojiCollectionView: UICollectionView!
    @IBOutlet private weak var menuCollectionView: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var emojiCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var menuCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var pageControlHeightConstraint: NSLayoutConstraint!
    
    private static var sharedView: ChatBottomMenuView?
    private let shapeLayer = CAShapeLayer()
    private var menuItems: [MenuItem]?
    private weak var delegate: ChatBottomMenuViewDelegate?
    private var userInfo: [String: Any]?
    private var isFold = true
    private let emojiList: [String] = ["ee_40", "ee_43", "ee_37", "ee_36", "ee_15", "ee_10", "add_reaction"]
    private let menuItemShowMap: [MenuItem: (String, String)] = [
        .recall: ("message_recall", "撤回"),
        .copy: ("message_copy", "复制"),
        .thread: ("message_thread", "子区")
    ]

    override func awakeFromNib() {
        super.awakeFromNib()
        self.mainView.layer.mask = self.shapeLayer
        self.emojiCollectionView.register(UINib(nibName: "EmojiListCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "reaction")
        self.menuCollectionView.register(UINib(nibName: "ChatBottomMenuViewItemCell", bundle: nil), forCellWithReuseIdentifier: "menu")
        if let layout = self.menuCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let corner: UIRectCorner = [.topLeft, .topRight]
        let path = UIBezierPath(roundedRect: self.mainView.bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: 16, height: 16))
        self.shapeLayer.frame = self.mainView.bounds
        self.shapeLayer.path = path.cgPath
    }
    
    class func show(menuItems: [MenuItem], delegate: ChatBottomMenuViewDelegate, userInfo: [String: Any]) {
        if sharedView == nil {
            guard let view = Bundle.main.loadNibNamed("ChatBottomMenuView", owner: nil)?.first as? ChatBottomMenuView else {
                return
            }
            self.sharedView = view
        }
        guard let sharedView = self.sharedView else {
            return
        }
        UIApplication.shared.keyWindow?.addSubview(sharedView)
        if let frame = UIApplication.shared.keyWindow?.bounds {
            sharedView.frame = frame
        }
        sharedView.menuItems = menuItems
        sharedView.delegate = delegate
        sharedView.userInfo = userInfo
        sharedView.isFold = true
        sharedView.pageControlHeightConstraint.constant = 0
        sharedView.pageControl.isHidden = true
        sharedView.emojiCollectionViewHeightConstraint.constant = 61
        sharedView.menuCollectionViewHeightConstraint.constant = 84
        sharedView.emojiCollectionView.reloadData()
        sharedView.menuCollectionView.reloadData()
    }
    
    class func hide() {
        self.sharedView?.removeFromSuperview()
    }
    
    @IBAction func tabAction(_ sender: UITapGestureRecognizer) {
        ChatBottomMenuView.hide()
    }
    
    @IBAction func pageControlValueChangeAction() {
        var offset = self.emojiCollectionView.contentOffset
        offset.x = CGFloat(self.pageControl.currentPage) * self.emojiCollectionView.bounds.width
        self.emojiCollectionView.contentOffset = offset
    }
}

extension ChatBottomMenuView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.emojiCollectionView {
            if self.isFold {
                return self.emojiList.count
            } else {
                return 47
            }
        } else {
            if self.isFold {
                return self.menuItems?.count ?? 0
            } else {
                return 0
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reaction", for: indexPath)
            if let cell = cell as? EmojiListCollectionViewCell {
                if self.isFold {
                    cell.imageName = self.emojiList[indexPath.item]
                } else {
                    cell.imageName = "ee_\(indexPath.item + 1)"
                }
                if let name = cell.imageName {
                    cell.isAdded = self.delegate?.chatBottomMenuViewGetIsAdded(view: self, reaction: name, userInfo: self.userInfo)
                } else {
                    cell.isAdded = false
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "menu", for: indexPath)
            if let cell = cell as? ChatBottomMenuViewItemCell, let item = self.menuItems?[indexPath.item], let showItem = self.menuItemShowMap[item] {
                cell.imageView.image = UIImage(named: showItem.0)
                cell.label.text = showItem.1
            }
            return cell
        }
    }
}

extension ChatBottomMenuView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.emojiCollectionView {
            if isFold {
                if indexPath.item >= self.emojiList.count - 1 {
                    self.isFold = false
                    self.menuCollectionViewHeightConstraint.constant = 0
                    self.pageControlHeightConstraint.constant = 38
                    self.emojiCollectionViewHeightConstraint.constant = 244
                    self.pageControl.isHidden = false
                    self.layoutIfNeeded()
                    self.emojiCollectionView.reloadData()
                } else {
                    self.delegate?.chatBottomMenuViewDidSelectedReaction(view: self, reaction: self.emojiList[indexPath.item], userInfo: self.userInfo)
                    ChatBottomMenuView.hide()
                }
            } else {
                self.delegate?.chatBottomMenuViewDidSelectedReaction(view: self, reaction: "ee_\(indexPath.item + 1)", userInfo: self.userInfo)
                ChatBottomMenuView.hide()
            }
        } else {
            if let item = self.menuItems?[indexPath.item] {
                self.delegate?.chatBottomMenuViewDidSelectedMenuItem(view: self, menuItem: item, userInfo: self.userInfo)
                ChatBottomMenuView.hide()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.emojiCollectionView {
            self.pageControl.currentPage = Int((scrollView.contentOffset.x + scrollView.bounds.width / 2) / scrollView.bounds.width)
        }
    }
}
