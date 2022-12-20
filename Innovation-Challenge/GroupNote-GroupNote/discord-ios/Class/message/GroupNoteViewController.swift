//
//  GroupNoteViewController.swift
//  discord-ios
//
//  Created by zky on 2022/12/17.
//

import UIKit
import SnapKit
import HyphenateChat

class GroupNoteViewController: UIViewController {

    private var activeTextView: UITextView?
    
    var didSendHandle: ((GroupNote) -> Void)?
    var tableViewHeight: NSLayoutConstraint?
    
    private var creating = true
    private var model: GroupNote?
    private var exampleExists: Bool {
        guard let model = model, let _ = model.example else { return false }
        return true
    }
    
    convenience init(model: GroupNote, creating: Bool) {
        self.init()
        self.model = model
        self.creating = creating
    }
    
    override func viewDidLoad() {
        setupView()
        
        if let initiator = model?.initiator,
            let userInfo = UserInfoManager.share.userInfo(userId: initiator) {
            
            portraitImageView.setImage(withUrl: userInfo.avatarUrl, placeholder: "head_placeholder")
            initiatorLabel.text = "由\(userInfo.showname!)发起接龙"
        }
    }
    
    @objc private func send() {
        
        if model?.example == "" {
            model?.example = nil
        }
        
        if let model = model {
            didSendHandle?(model)
        }
        
        dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        activeTextView?.resignFirstResponder()
        activeTextView = nil
    }
    
    @objc private func addPost() {
        guard let post = GroupNote.selfPost() else { return }
        model?.posts.append(post)
        postsView.reloadData()
    }
    
    private func addDismissKeyboardGestureForView(_ view: UIView) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: -- Lazy subviews
    
    private func setupView() {
        view.backgroundColor = UIColor(named: ColorName_181818)
        title = "接龙结果"
        noteTextView.text = model?.noteMessage
        if !creating {
            noteTextView.isEditable = false
        }
        _ = sendButton
        
        view.addSubview(portraitImageView)
        view.addSubview(initiatorLabel)
        view.addSubview(noteTextView)
        view.addSubview(postsView)
        view.addSubview(addPostButton)
        
        addDismissKeyboardGestureForView(view)
        
        portraitImageView.snp.makeConstraints { (make) -> Void in
            make.width.height.equalTo(24)
            make.leading.equalTo(30)
            make.top.equalTo(60)
        }
        
        initiatorLabel.snp.makeConstraints { make in
            make.leading.equalTo(portraitImageView.snp.trailing).offset(8)
            make.centerY.equalTo(portraitImageView)
            make.trailing.equalTo(-30)
        }
        
        noteTextView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(portraitImageView.snp.bottom).offset(10)
            make.leading.equalTo(portraitImageView)
            make.trailing.equalTo(-50)
            make.height.equalTo(100)
        }
        
        postsView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(noteTextView.snp.bottom).offset(30)
            make.leading.equalTo(noteTextView)
            make.trailing.equalTo(noteTextView)
        }
        
        addPostButton.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(postsView.snp.bottom).offset(10)
            make.width.equalTo(50)
            make.height.equalTo(40)
            make.leading.equalTo(noteTextView)
        }
        
        tableViewHeight = NSLayoutConstraint(item: postsView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 10)
        tableViewHeight?.isActive = true
        
        noteTextView.becomeFirstResponder()
        activeTextView = noteTextView
    }
    
    private lazy var portraitImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.layer.cornerRadius = 4
        imageView.layer.masksToBounds = true

        return imageView
    }()
    
    private lazy var initiatorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: ColorName_979797)
        return label
    }()
    
    private lazy var noteTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .white
        textView.delegate = self
        
        return textView
    }()
    
    private lazy var postsView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.rowHeight = 50
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(GroupNotePostCell.self, forCellReuseIdentifier: String(describing: GroupNotePostCell.self))
        
        return tableView
    }()
    
    private lazy var addPostButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "add_button"), for: .normal)
        button.addTarget(self, action: #selector(addPost), for: .touchUpInside)
        return button
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("发送", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.setTitleColor(UIColor(named: ColorName_979797), for: .disabled)
        button.setTitleColor(UIColor(named: ColorName_27AE60), for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        return button
    }()
    
    private lazy var complementTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()
}

extension GroupNoteViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = model else { return 0 }
        return model.posts.count + (exampleExists ? 1 : 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GroupNotePostCell = tableView.dequeueReusableCell()
        
        if indexPath.row == 0, let exampleText = model?.example {
            cell.setModel(sequenceText: "例", postText: exampleText, placeholder: "可填写接龙格式")
            if EMClient.shared().currentUsername != model?.initiator {
                cell.setModifiable(false)
            }
        } else {
            let sequenceText = "\(indexPath.row + (exampleExists ? 0 : 1))"
            let postText = model?.posts[indexPath.row - (exampleExists ? 1 : 0)].postMessage
            let userId = model?.posts[indexPath.row - (exampleExists ? 1 : 0)].userId
            cell.setModel(sequenceText: sequenceText, postText: postText)
            
            if EMClient.shared().currentUsername != userId {
                cell.setModifiable(false)
            }
        }
        
        cell.didBeginEditing = { [unowned self] textView in
            self.activeTextView = textView
        }
        
        cell.textChanged = { [unowned self] postText in
            if indexPath.row == 0, let _ = self.model?.example {
                self.model?.example = postText
            } else {
                var index = indexPath.row
                if let _ = self.model?.example {
                    index -= 1
                }
                self.model?.posts[index].postMessage = postText
            }
        }

        return cell
    }
}

extension GroupNoteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableViewHeight?.constant = tableView.contentSize.height
        tableView.layoutIfNeeded()
    }
}

extension GroupNoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        activeTextView = textView
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView === noteTextView {
            model?.noteMessage = noteTextView.text
        }
    }
}
