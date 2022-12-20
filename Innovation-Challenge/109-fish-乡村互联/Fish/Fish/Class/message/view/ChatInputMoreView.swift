//
//  ChatInputMoreView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/22.
//

import UIKit

class ChatInputMoreView: UIView {
    
    enum ShowItem {
        case camera
        case photoLibrary
        case file
    }
    
    private let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

    private let dataList: [ShowItem] = [.photoLibrary, .camera, .file]
    var didSelectItemHandle: ((_ item: ShowItem) -> Void)?
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionView.frame = self.bounds
    }
    
    private func selfInit() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "ChatBottomMenuViewItemCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.addSubview(self.collectionView)
        self.collectionView.backgroundColor = UIColor.clear
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 22, left: 12, bottom: 0, right: 12)
            layout.itemSize = CGSize(width: 84, height: 84)
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
    }
}

extension ChatInputMoreView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ChatBottomMenuViewItemCell {
            let item = self.dataList[indexPath.item]
            switch item {
            case .camera:
                cell.label.text = "相机"
                cell.imageView.image = UIImage(named: "input_more_camera")
            case .photoLibrary:
                cell.label.text = "照片"
                cell.imageView.image = UIImage(named: "input_more_image")
            case .file:
                cell.label.text = "文件"
                cell.imageView.image = UIImage(named: "input_more_file")
            }
        }
        return cell
    }
}

extension ChatInputMoreView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didSelectItemHandle?(self.dataList[indexPath.item])
    }
}
