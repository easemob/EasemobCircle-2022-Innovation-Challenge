//
//  ServerPoint.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/11/25.
//

import Foundation
import HyphenateChat
import TagListView
import BadgeSwift

enum CircleSearchResultLocal {
    case server(EMCircleServer)
    case channel(EMCircleChannel)
}

protocol CellIdentifier {
    var identifier: String { get }
}

extension CircleSearchResultLocal: SearchItem {

    var identifier: String {
        guard case .channel(let eMCircleChannel) = self else {
            return CircleDefaultChannelCell.identifier
        }
        return eMCircleChannel.isDefault ? CircleDefaultChannelCell.identifier : CircleChannelCell.identifier
    }
    
    var server: EMCircleServer? {
        guard case .server(let eMCircleServer) = self else {
            return nil
        }
        return eMCircleServer
    }
    
    var channel: EMCircleChannel? {
        guard case .channel(let eMCircleChannel) = self else {
            return nil
        }
        
        return eMCircleChannel
    }
}

extension EMCircleServer: SearchItem {
    
    var identifier: String {
        CircleDefaultChannelCell.identifier
    }
    
    var server: EMCircleServer? { self }
}

enum SearchServerResult {
    case local([CircleSearchResultLocal])
    case remote([EMCircleServer])
    case nearby([EMCircleServer])
}

protocol SearchItem: CellIdentifier {
    var server: EMCircleServer? { get }
    var channel: EMCircleChannel? { get }
}

extension SearchItem {
    
    var server: EMCircleServer? { nil }
    var channel: EMCircleChannel? { nil }
}

extension SearchServerResult {
    
    func items() -> [SearchItem] {
        switch self {
        case .local(let v):
            return v
        case .remote(let v):
            return v
        case .nearby(let v):
            return v
        }
    }
    
    var count: Int {
        items().count
    }
    
    var sectionHeader: String {
        switch self {
        case .local:
            return "加入的社群"
        case .remote:
            return "网络上的社群"
        case .nearby:
            return "附近的社群"
        }
    }
}

protocol SearchItemCell: UITableViewCell {
    
    func configure(_ item: SearchItem)
}

class CircleChannelCell: UITableViewCell {
    
    static let identifier = "CircleChannelCell"
    
    var circleManager: IEMCircleManager {
        EMClient.shared().circleManager!
    }
    
    @IBOutlet weak var colorView: UIView?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var descLabel: UILabel?
    @IBOutlet weak var unreadLabel: BadgeSwift?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView?.layer.cornerRadius = 8.0
    }
    
    func configure(_ channel: EMCircleChannel) {

        let ext = channel.custom
        
        colorView?.backgroundColor = ext?.color
        descLabel?.text = channel.desc
        
        let attr = NSMutableAttributedString(string: channel.name, attributes: [.font: UIFont.systemFont(ofSize: 17), .foregroundColor: UIColor.label])
        
        if (!channel.isIn) {
            attr.append(NSAttributedString(string: " #未加入", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: ext?.color ?? UIColor.accent]))
        }
        nameLabel?.attributedText = attr
        
        let count = EMClient.shared().chatManager?.getConversation(channel.channelId, type: .groupChat, createIfNotExist: false)?.unreadMessagesCount ?? 0
        
        if count == 0 {
            unreadLabel?.removeFromSuperview()
        }
        
        unreadLabel?.text = "\(count)"
        unreadLabel?.badgeColor = ext?.color ?? UIColor.systemRed
    }
        
}

class CircleDefaultChannelCell: UITableViewCell {
    
    static let identifier = "CircleDefaultChannelCell"
    
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var desLabel: UILabel?
    @IBOutlet weak var tagView: TagListView?
    
    func configure(_ server: EMCircleServer) {
        
        let name = "# " + server.name
        nameLabel?.text = name
        
        let attr = NSMutableAttributedString(string: name, attributes: [.font: UIFont.systemFont(ofSize: 18.0, weight: .medium), .foregroundColor: UIColor.label])
        
        attr.append(NSAttributedString(string: "@" + server.owner!, attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.accent]))
        
        nameLabel?.attributedText = attr
        
        desLabel?.text = server.desc
        
        tagView?.removeAllTags()
        
        if let tags = server.tags, !tags.isEmpty {
            tagView?.addTags(tags.compactMap { $0.name })
        } else {
            EMClient.shared().circleManager?.fetchServerTags(server.serverId, completion: { [unowned self] allTags, _ in
                if let tags = allTags, !tags.isEmpty {
                    tagView?.addTags(tags.compactMap { $0.name })
                }
                server.tags = allTags
            })
        }
    }
    
    override func prepareForReuse() {
        tagView?.removeAllTags()
    }
}


extension CircleDefaultChannelCell: SearchItemCell {
    
    func configure(_ item: SearchItem) {
        guard let server = item.server else {
            fatalError()
        }
        configure(server)
    }
}

extension CircleChannelCell: SearchItemCell {
    
    func configure(_ item: SearchItem) {
        guard let channel = item.channel else {
            fatalError()
        }
        configure(channel)
    }
}
