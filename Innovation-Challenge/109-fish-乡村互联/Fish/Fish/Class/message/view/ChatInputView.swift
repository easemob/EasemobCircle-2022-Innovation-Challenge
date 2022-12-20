//
//  ChatInputView.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/4.
//

import UIKit
import SnapKit

class ChatInputView: UIView {
    
    private enum ShowType {
        case normal
        case keyboard
        case emoji
        case more
    }
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var placeholderLabel: UILabel!
    @IBOutlet weak var emojiButton: UIButton!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var emojiListView: EmojiListView!
    @IBOutlet private weak var moreView: ChatInputMoreView!
    @IBOutlet private weak var inputViewBottomConstraint: NSLayoutConstraint!
    
    private var showType: ShowType = .normal {
        didSet {
            switch self.showType {
            case .emoji:
                self.moreButton.setBackgroundImage(UIImage(named: "input_bar_send"), for: .normal)
                self.emojiButton.setBackgroundImage(UIImage(named: "input_bar_keyboard"), for: .normal)
                self.emojiListView.isHidden = false
                self.moreView.isHidden = true
            case .more:
                self.moreButton.setBackgroundImage(UIImage(named: "input_bar_close"), for: .normal)
                self.emojiButton.setBackgroundImage(UIImage(named: "input_bar_emoji"), for: .normal)
                self.emojiListView.isHidden = true
                self.moreView.isHidden = false
            default:
                self.moreButton.setBackgroundImage(UIImage(named: "input_bar_more"), for: .normal)
                self.emojiButton.setBackgroundImage(UIImage(named: "input_bar_emoji"), for: .normal)
                self.emojiListView.isHidden = true
                self.moreView.isHidden = true
            }
            if self.showType != oldValue {
                self.showTypeChangeHandle?()
            }
        }
    }
    
    var text: String? {
        if let attributeString = self.textView.attributedText {
            return attributeString.toString()
        }
        return self.textView.text
    }
    
    var heightChangeHandle: ((_ height: CGFloat, _ duration: CGFloat) -> Void)?
    var sendHandle: ((_ text: String) -> Void)?
    var didSelectedMoreItemHandle: ((_ item: ChatInputMoreView.ShowItem) -> Void)?
    var showTypeChangeHandle: (() -> Void)?
    
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
        guard let view = Bundle.main.loadNibNamed("ChatInputView", owner: self)?.first as? UIView else {
            return
        }
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        self.inputViewBottomConstraint.constant = 0
        self.emojiListView.isHidden = true
        self.moreView.isHidden = true
        
        self.emojiListView.didSelectedEmojiHandle = { [unowned self] emoji in
            let old = self.textView.attributedText ?? NSAttributedString()
            let new = old.appendEmoji(emoji: emoji, fontSize: 17)
            self.textView.attributedText = new
            self.placeholderLabel.isHidden = true
        }
        self.emojiListView.didClickDeleteHandle = { [unowned self] in
            self.textView.deleteBackward()
        }
        
        self.moreView.didSelectItemHandle = { [unowned self] item in
            self.didSelectedMoreItemHandle?(item)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvkeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        self.reset()
        return self.textView.resignFirstResponder()
    }
    
    func reset() {
        if self.showType == .normal {
            return
        }
        self.inputViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25) {
            self.superview?.layoutIfNeeded()
        }
        self.showType = .normal
    }
    
    @IBAction private func emojiAction() {
        if self.showType == .emoji {
            self.textView.becomeFirstResponder()
            self.showType = .keyboard
        } else {
            self.textView.resignFirstResponder()
            self.inputViewBottomConstraint.constant = self.emojiListView.bounds.height
            UIView.animate(withDuration: 0.25) {
                self.superview?.layoutIfNeeded()
            }
            self.showType = .emoji
        }
    }
    
    @IBAction func moreAction() {
        if self.showType == .emoji {
            self.sendHandle?(self.textView.attributedText.toString())
            self.textView.text = nil
            self.placeholderLabel.isHidden = false
        } else if self.showType == .more {
            self.textView.becomeFirstResponder()
            self.showType = .keyboard
        } else {
            self.textView.resignFirstResponder()
            self.inputViewBottomConstraint.constant = self.moreView.bounds.height
            UIView.animate(withDuration: 0.25) {
                self.superview?.layoutIfNeeded()
            }
            self.showType = .more
        }
    }
    
    @objc private func didRecvkeyboardWillShowNotification(_ notification: Notification) {
        self.showType = .keyboard
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat
        if let endFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.inputViewBottomConstraint.constant = endFrame.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
            UIView.animate(withDuration: duration ?? 0.25) {
                self.superview?.layoutIfNeeded()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ChatInputView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.sendHandle?(self.textView.attributedText.toString())
            self.textView.text = nil
            self.placeholderLabel.isHidden = false
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        self.placeholderLabel.isHidden = textView.text.count > 0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.showType = .keyboard
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.showType == .keyboard {
            self.reset()
        }
    }
}
