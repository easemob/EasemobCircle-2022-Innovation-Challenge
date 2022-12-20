//
//  GroupNotePostCell.swift
//  discord-ios
//
//  Created by zky on 2022/12/18.
//

import UIKit
import SnapKit

class GroupNotePostCell: UITableViewCell {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var didBeginEditing: ((UITextView) -> Void)?
    var textChanged: ((String) -> Void)?
    var placeholderLabel : UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    func setModel(sequenceText: String, postText: String? = nil, placeholder: String? = nil) {
        sequenceLabel.text = sequenceText
        postTextView.text = postText
        
        if placeholder != nil {
            placeholderLabel = UILabel()
            placeholderLabel.text = placeholder
            placeholderLabel.font = .italicSystemFont(ofSize: (postTextView.font?.pointSize)!)
            placeholderLabel.sizeToFit()
            postTextView.addSubview(placeholderLabel)
            placeholderLabel.frame.origin = CGPoint(x: 5, y: (postTextView.font?.pointSize)! / 2)
            placeholderLabel.textColor = UIColor(named: ColorName_979797)
            placeholderLabel.isHidden = !postTextView.text.isEmpty
        }
    }
    
    func setModifiable(_ modifiable: Bool) {
        postTextView.textColor = UIColor(named: ColorName_979797)
        postTextView.isEditable = modifiable
    }
    
    private func setupView() {
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(sequenceLabel)
        contentView.addSubview(postTextView)
        
        sequenceLabel.snp.makeConstraints { (make) -> Void in
            make.height.width.equalTo(28)
            make.leading.equalTo(0)
            make.centerY.equalTo(contentView)
        }
        
        postTextView.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(32)
            make.leading.equalTo(sequenceLabel.snp.trailing).offset(10)
            make.trailing.equalTo(contentView)
            make.centerY.equalTo(contentView)
        }
    }
    
    private lazy var sequenceLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 14
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = UIColor(named: "#414042")
        label.textColor = UIColor(named: ColorName_979797)
        return label
    }()
    
    private lazy var postTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 2
        textView.layer.masksToBounds = true
        textView.backgroundColor = UIColor(named: "#414042")
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = self
        return textView
    }()
}

extension GroupNotePostCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?(textView)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        textChanged?(textView.text)
        placeholderLabel.isHidden = !postTextView.text.isEmpty
    }
}
