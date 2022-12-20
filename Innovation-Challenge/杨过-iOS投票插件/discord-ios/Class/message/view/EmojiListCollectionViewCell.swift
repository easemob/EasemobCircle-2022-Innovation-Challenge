//
//  EmojiListCollectionViewCell.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/4.
//

import UIKit

class EmojiListCollectionViewCell: UICollectionViewCell {

    @IBOutlet private weak var bgView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.layer.borderColor = UIColor(named: ColorName_27AE60)?.cgColor
    }
    
    var imageName: String? {
        didSet {
            if let imageName = imageName {
                self.imageView.image = UIImage(named: imageName)
            } else {
                self.imageView.image = nil
            }
            self.imageView.isHidden = false
        }
    }
    
    var isAdded: Bool? {
        didSet {
            self.bgView.isHidden = self.isAdded != true
        }
    }
}
