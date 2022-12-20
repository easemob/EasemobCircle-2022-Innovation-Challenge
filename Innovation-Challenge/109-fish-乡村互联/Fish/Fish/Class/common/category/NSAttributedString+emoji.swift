//
//  NSAttributedString+emoji.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/11.
//

import UIKit

private let list: [String] = ["[):]", "[:D]", "[;)]", "[:-o]", "[:p]", "[(H)]", "[:@]", "[:s]", "[:$]", "[:(]", "[:'(]", "[:|]", "[(a)]", "[8o|]", "[8-|]", "[+o(]", "[<o)]", "[(U)]", "[|-)]", "[*-)]", "[:-#]", "[:-*]", "[^o)]", "[8-)]", "[(|)]", "[(u)]", "[(S)]", "[(*)]", "[(#)]", "[(R)]", "[({)]", "[(})]", "[(k)]", "[(F)]", "[(Z)]", "[(W)]", "[(D)]", "[(E)]", "[(T)]", "[(G)]", "[(Y)]", "[(I)]", "[(K)]", "[(L)]", "[(M)]", "[(N)]", "[(O)]"]

private var emojiTextMap: [String: String]  = {
    var map: [String: String] = [:]
    for i in 0..<list.count {
        map["ee_\(i + 1)"] = list[i]
    }
    return map
}()

private var textEmojiMap: [String: String]  = {
    var map: [String: String] = [:]
    for i in 0..<list.count {
        map[list[i]] = "ee_\(i + 1)"
    }
    return map
}()

func emojiImageName(text: String) -> String? {
    return textEmojiMap[text]
}

func imageNameEmoji(emoji: String) -> String? {
    return emojiTextMap[emoji]
}

extension NSAttributedString {
    func appendEmoji(emoji: String, fontSize: CGFloat) -> NSAttributedString {
        let attributedText = NSMutableAttributedString()
        attributedText.append(self)
        if let image = UIImage(named: emoji) {
            let attachment = NSTextAttachment(data: nil, ofType: nil)
            attachment.image = image
            attachment.bounds = CGRect(x: 0, y: -6, width: 24, height: 24)
            let new = NSMutableAttributedString(attachment: attachment)
            new.addAttributes([
                .font: UIFont.systemFont(ofSize: fontSize),
                .foregroundColor: UIColor.white,
                .accessibilityTextCustom: emojiTextMap[emoji] ?? ""
            ], range: NSRange(location: 0, length: new.length))
            attributedText.append(new)
        }
        return attributedText
    }
    
    public convenience init(emojiText: String, fontSize: CGFloat) {
        let attributedString = NSMutableAttributedString(string: emojiText)
        let regular = try? NSRegularExpression(pattern: "\\[.+?\\]", options: .caseInsensitive)
        if let result = regular?.matches(in: emojiText, options: [], range: NSRange(location: 0, length: emojiText.count)) {
            for i in result.reversed() {
                let start = emojiText.index(emojiText.startIndex, offsetBy: i.range.location)
                let end = emojiText.index(emojiText.startIndex, offsetBy: i.range.location + i.range.length - 1)
                if let emoji = textEmojiMap[String(emojiText[start...end])] {
                    let attachment = NSTextAttachment(data: nil, ofType: nil)
                    attachment.image = UIImage(named: emoji)
                    attachment.bounds = CGRect(x: 0, y: -5, width: 20, height: 20)
                    let new = NSMutableAttributedString(attachment: attachment)
                    new.addAttributes([
                        .font: UIFont.systemFont(ofSize: fontSize),
                        .accessibilityTextCustom: emojiTextMap[emoji] ?? ""
                    ], range: NSRange(location: 0, length: new.length))
                    attributedString.replaceCharacters(in: i.range, with: new)
                } else {
                    print("\(String(emojiText[start...end]))")
                }
            }
        }
        self.init(attributedString: attributedString)
    }
    
    func toString() -> String {
        let result = NSMutableAttributedString(attributedString: self)
        var replaceList: [(NSRange, String)] = []
        result.enumerateAttribute(.accessibilityTextCustom, in: NSRange(location: 0, length: result.length), using: { value, range, _ in
            if let value = value as? String {
                for i in range.location..<range.location + range.length {
                    replaceList.append((NSRange(location: i, length: 1), value))
                }
            }
        })
        for i in replaceList.reversed() {
            result.replaceCharacters(in: i.0, with: i.1)
        }
        return result.string
    }
}
