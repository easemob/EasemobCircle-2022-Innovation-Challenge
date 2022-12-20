//
//  TagListView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/6/21.
//

import UIKit
import HyphenateChat

class ServerTagListView: UIView {

    private static var tagViewPool: Set<ServerTagView> = Set()
    
    private var tagViews: [ServerTagView] = []
    public var deleteHandle: ((_ tag: EMCircleServerTag?) -> Void)?
    public var heightChangeHandle: ((_ height: CGFloat) -> Void)?
    
    private var tags: [EMCircleServerTag]?
    private var itemHeight: CGFloat = 0
    private var showDelete = false
    private var newLine = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let tags = self.tags, tags.count > 0 else {
            self.clearAll()
            return
        }
        if tags.count < self.tagViews.count {
            self.removeTagViews(fromIndex: tags.count)
        }
        
        var beginX: CGFloat = 0
        var beginY: CGFloat = 0
        let space: CGFloat = self.showDelete ? 12 : 8
        for i in 0..<tags.count {
            if ServerTagView.minWidth(showDelete: self.showDelete) + beginX > self.bounds.width {
                if !newLine {
                    self.removeTagViews(fromIndex: i)
                    break
                }
            }
            var tagView: ServerTagView!
            if i < self.tagViews.count {
                tagView = self.tagViews[i]
            } else {
                tagView = ServerTagListView.tagViewPool.popFirst()
                if tagView == nil {
                    tagView = ServerTagView()
                }
                tagView.showDelete = showDelete
                self.tagViews.append(tagView)
                self.addSubview(tagView)
            }
            tagView.serverTag = tags[i].name
            tagView.deleteHandle = { [weak self] tag in
                if let tags = self?.tags {
                    for item in tags where item.name == tag {
                        self?.deleteHandle?(item)
                    }
                }
            }
            
            if newLine && beginX + tagView.maxWidth > self.bounds.width {
                beginY += self.itemHeight + 4
                beginX = 0
            }
            let width = beginX + tagView.maxWidth > self.bounds.width ? self.bounds.width - beginX : tagView.maxWidth
            tagView.frame = CGRect(x: beginX, y: beginY, width: width, height: itemHeight)
            beginX += tagView.maxWidth + space
        }
        
        self.heightChangeHandle?(self.tagViews.last?.frame.maxY ?? 0)
    }
    
    public func setTags(_ tags: [EMCircleServerTag]?, itemHeight: CGFloat, showDelete: Bool = false, newLine: Bool = false) {
        self.tags = tags
        self.itemHeight = itemHeight
        self.showDelete = showDelete
        self.newLine = newLine
        self.setNeedsLayout()
    }
    
    private func clearAll() {
        for tagView in self.tagViews {
            tagView.removeFromSuperview()
            ServerTagListView.tagViewPool.insert(tagView)
        }
        self.tagViews.removeAll()
    }
    
    private func removeTagViews(fromIndex: Int) {
        for i in fromIndex..<self.tagViews.count {
            let tagView = self.tagViews[i]
            tagView.removeFromSuperview()
            ServerTagListView.tagViewPool.insert(tagView)
        }
        if self.tagViews.count > fromIndex {
            self.tagViews.removeSubrange(fromIndex..<self.tagViews.count)
        }
    }
}
