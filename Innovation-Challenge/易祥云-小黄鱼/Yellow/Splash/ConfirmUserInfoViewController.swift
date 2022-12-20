//
//  ConfirmUserInfoViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/23.
//

import UIKit
import LTMorphingLabel
import HyphenateChat
import SPIndicator

class ConfirmUserInfoViewController: UITableViewController {
    
    ///
    var allEmojis: [Emoji] {
        return EmojiCategory.animals.emojis
    }
    
    var avatarChar: String! {
        didSet {
            avatarLabel.text = avatarChar
        }
    }
    
    @IBOutlet var avatarLabel: LTMorphingLabel!
    
    @IBOutlet var collectionView: UICollectionView?
    
    ////
    var nickname: String! {
        didSet {
            nicknameLabel.text = nickname
        }
    }
    
    @IBOutlet var nicknameLabel: LTMorphingLabel!

    ///
    @IBOutlet var genderControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 阻止下拉隐藏
        isModalInPresentation = true
        
        tableView.allowsSelection = false
               
        avatarLabel.morphingEffect = .fall
        nicknameLabel.morphingEffect = .evaporate
        
        random()
    }
    
    private func random() {
        
        let avatar = Int.random(in: 0..<allEmojis.count)
        avatarChar = allEmojis[avatar].char
     
        collectionView?.selectItem(at: IndexPath(item: avatar, section: 0), animated: true, scrollPosition: .centeredVertically)
        
        let nn = Int.random(in: 0..<nickNameSource.count)
        nickname = nickNameSource[nn]
        
        genderControl.selectedSegmentIndex = Int.random(in: 0..<genderControl.numberOfSegments)
    }
    
    @IBAction func onTapDone(_ sender: UIBarButtonItem) {
        
        let userInfo = EMUserInfo()
        
        userInfo.nickname = nickname
        userInfo.avatarUrl = avatarChar
        
        // 1 男 2 女 3 其他
        userInfo.gender = genderControl.selectedSegmentIndex + 1
        
        UserInfoManager.shared.updateOwn(userInfo) { error in
            
            DispatchQueue.main.async { [weak self] in
            
                guard error == nil else {
                    SPIndicator.present(title: "您的身份信息保存失败，请重试", haptic: .error)
                    return
                }
                
                self?.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func onTapRefresh(_ sender: UIBarButtonItem) {
        random()
    }
    
}

extension Notification.Name {
    
    static let ownUserInfoUpdated = Notification.Name(rawValue: "OwnUserInfoUpdated")
}

class EmojiCell: UICollectionViewCell {
    
    @IBOutlet var label: UILabel!
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        UIView.animate(withDuration: 0.4) {
            self.contentView.backgroundColor = self.isSelected ? UIColor.systemGroupedBackground : .clear
            self.contentView.layer.cornerRadius = self.isSelected ? 8.0 : 0.0
        }
    }

}

extension ConfirmUserInfoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allEmojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "emojiCell", for: indexPath) as? EmojiCell else {
            fatalError()
        }
        
        cell.label.text = allEmojis[indexPath.item].char
        
        return cell
    }
}

extension ConfirmUserInfoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let emoji = allEmojis[indexPath.item]
        avatarChar = emoji.char
    }
   
}
