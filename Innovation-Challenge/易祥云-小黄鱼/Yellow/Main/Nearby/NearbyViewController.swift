//
//  NearbyViewController.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/12/1.
//

import UIKit
import HyphenateChat

//https://github.com/HamzaGhazouani/HGPlaceholders

class NearbyViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView?
    
    @IBOutlet weak var collectionViewLayout: UICollectionViewFlowLayout?
    
    fileprivate var users = [NearbyUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "旁边的人"
       
        collectionView?.alwaysBounceVertical = true
        
        NearbyPoint.instance.render = self
        
        collectionView?.emptyDataSetView({ view in
            view.titleLabelString(NSAttributedString(string: "小黄鱼都游走了～"))
            .detailLabelString(NSAttributedString(string: "你周围暂时没有小黄鱼用户，赶紧推荐给朋友体验一下。小黄鱼支持无网络聊天哦"))
        })
        
        reload()
    }
    
}

extension NearbyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? NearbyCollectioinViewCell else {
            fatalError()
        }
        
        cell.configure(with: users[indexPath.item])
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let u = users[indexPath.item]
        
        let ac = UIAlertController(title: "确认向 \(u.nickname) 打招呼吗?", message: nil, preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "是", style: .default) { [weak self] _ in
                
            // 尝试发消息，如果发送不成功就尝试p2p的方式发送
            
            if EMClient.shared().isConnected {
                // 通过环信发
                let body = EMCustomMessageBody(event: "hi", customExt: nil)
                let message = EMChatMessage(conversationID: u.userId, body: body, ext: nil)
                
                EMClient.shared().chatManager?.send(message, progress: nil)
            } else {
                // 通过session发
                let session = MCSessionHolder.shared.session
                
                try? session?.send("hi".data(using: .utf8)!, toPeers: [u.peer], with: .reliable)
            }
            
            // 跳转到聊天页面
            let vc = ChatViewController.newInstanceFromStoryboard(with: u.userId)
            
            self?.navigationController?.show(vc, sender: nil)
        })
        
        ac.addAction(UIAlertAction(title: "暂不", style: .cancel))
        
        present(ac, animated: true)
    }
        
}

extension NearbyViewController: NearbyUserRender {
    
    func reload() {
        
        users = NearbyPoint.instance.nearbyUsers.sorted(by: { nl, nr in
            nl.distance > nl.distance
        })
        
        collectionView?.reloadData()
        collectionView?.reloadEmptyDataSet()
    }
}

class NearbyCollectioinViewCell: UICollectionViewCell {
    
    @IBOutlet weak var avatarContainer: UIView?
    @IBOutlet weak var avatarLabel: UILabel?
    
    @IBOutlet weak var nicknameLabel: UILabel?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        avatarContainer?.layer.cornerRadius = 40
    }
    
    func configure(with user: NearbyUser) {
        
        avatarLabel?.text = user.avatar
        
        let attr = NSMutableAttributedString(string: user.nickname, attributes: [.foregroundColor: UIColor.label, .font: UIFont.systemFont(ofSize: 16)])
        attr.append(NSAttributedString(string: String(format: "\n%.2f米", user.distance), attributes: [.foregroundColor: UIColor.accent, .font: UIFont.systemFont(ofSize: 14)]))
        
        nicknameLabel?.attributedText = attr
    }
}
