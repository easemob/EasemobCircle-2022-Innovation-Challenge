//
//  ChannelCollectionView.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/24.
//

import UIKit
import HyphenateChat

class ChannelCollectionViewCell: UICollectionViewCell {

    static let identifier = "cell"
    
    @IBOutlet weak var label: UILabel?
    
}

class ChatChannelViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var layout: UICollectionViewFlowLayout?
    
    override func viewDidLoad() {
        
        layout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    func reloadChannel(_ channels: [EMCircleChannel]) {
        self.channels = channels
        (view as? UICollectionView)?.reloadData()
    }
    
    private var channels = [EMCircleChannel]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return channels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ChannelCollectionViewCell else {
            fatalError()
        }
        
        let channel = channels[indexPath.item]
        
        cell.label?.text = channel.name
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
