//
//  ThreadCreateViewController.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/11.
//

import UIKit
import HyphenateChat
import SnapKit
import PKHUD
import TZImagePickerController

class ThreadCreateViewController: BaseViewController {

    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var clearButton: UIButton!
    @IBOutlet private weak var messageView: UIView!
    @IBOutlet private weak var sendMessageLabel: UILabel!
    @IBOutlet private weak var chatInputView: ChatInputView!
    
    private let chatType: ChatType
    private let message: EMChatMessage
    private var threadId: ThreadId?
    
    var threadCreatedHandle: (() -> Void)?
    
    init(chatType: ChatType, message: EMChatMessage) {
        self.chatType = chatType
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "创建子区"
        self.textField.attributedPlaceholder = NSAttributedString(string: "必填项", attributes: [
            .foregroundColor: UIColor(named: ColorName_A7A9AC)!
        ])
        self.textField.becomeFirstResponder()
        self.textField.setMaxLength(16) { [unowned self] length in
            self.countLabel.text = "\(length)/16"
            if length > 0 {
                self.clearButton.isHidden = false
                self.sendMessageLabel.textColor = UIColor(named: ColorName_CCCCCC)
            } else {
                self.clearButton.isHidden = true
                self.sendMessageLabel.textColor = UIColor(named: ColorName_4D4D4D)
            }
        }
        
        self.updateMessageView()
        self.setupChatInputView()
    }
    
    private func setupChatInputView() {
        self.chatInputView.isUserInteractionEnabled = false
        self.chatInputView.alpha = 0.6
        self.view.addSubview(self.chatInputView)
        self.chatInputView.snp.makeConstraints { make in
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        self.chatInputView.sendHandle = { [unowned self] text in
            if text.count <= 0 {
                Toast.show("消息不能为空", duration: 2)
                return
            }
            let body = EMTextMessageBody(text: text)
            self.createAction(messageBody: body)
        }
        self.chatInputView.didSelectedMoreItemHandle = { [unowned self] item in
            switch item {
            case .photoLibrary:
                PHPhotoLibrary.request {
                    if let vc = TZImagePickerController(maxImagesCount: 1, delegate: nil) {
                        vc.allowPickingOriginalPhoto = false
                        vc.didFinishPickingPhotosHandle = { images, _, _ in
                            guard let image = images?.first, let data = image.jpegData(compressionQuality: 1) else {
                                return
                            }
                            let body = EMImageMessageBody(data: data, displayName: "image")
                            body.size = image.size
                            self.createAction(messageBody: body)
                        }
                        self.present(vc, animated: true)
                    }
                }
            case .camera:
                let vc = UIImagePickerController()
                vc.sourceType = .camera
                vc.delegate = self
                self.present(vc, animated: true)
            case .file:
                if #available(iOS 14.0, *) {
                    let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.content, .text, .sourceCode, .image, .jpeg, .png, .pdf, .mp3])
                    vc.delegate = self
                    self.present(vc, animated: true)
                } else {
                    let vc = UIDocumentPickerViewController(documentTypes: ["public.content", "public.text", "public.source-code", "public.image", "public.jpeg", "public.png", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt"], in: .open)
                    vc.delegate = self
                    self.present(vc, animated: true)
                }
            case .groupNote:
                break
            }
        }
    }
    
    private func updateMessageView() {
        let cell = ThreadUtils.createMessageCell(message: self.message)
        guard let cell = cell else {
            return
        }
        self.messageView.addSubview(cell.contentView)
        cell.contentView.snp.makeConstraints { make in
            make.edges.equalTo(0)
        }
        for constraint in self.messageView.constraints where constraint.firstAttribute == .height {
            self.messageView.removeConstraint(constraint)
        }
    }
    
    private func createAction(messageBody: EMMessageBody) {
        guard let name = self.textField.text, name.count > 0 else {
            Toast.show("请输入子区名称", duration: 2)
            return
        }
        if self.threadId != nil {
            self.sendMessage(body: messageBody)
        } else {
            HUD.show(.progress, onView: self.view)
            EMClient.shared().threadManager?.createChatThread(name, messageId: self.message.messageId, parentId: self.chatType.conversationId) { thread, error in
                HUD.hide()
                if let error = error {
                    Toast.show(error.errorDescription, duration: 2)
                } else if let thread = thread {
                    self.textField.isEnabled = false
                    if let threadId = self.chatType.createThreadId(threadId: thread.threadId) {
                        self.threadId = threadId
                        self.sendMessage(body: messageBody)
                    }
                }
            }
        }
    }
    
    @IBAction func clearAction() {
        self.textField.text = nil
    }
    
    private func sendMessage(body: EMMessageBody) {
        guard let threadId = threadId else {
            return
        }
        guard let message = EMClient.shared().chatManager?.createSendMessage(body: body, chatType: .thread(threadId: threadId)) else {
            return
        }
        HUD.show(.progress, onView: self.view)
        EMClient.shared().chatManager?.send(message, progress: nil) { _, error in
            HUD.hide()
            if let error = error {
                Toast.show(error.errorDescription, duration: 2)
            } else {
                let vc = ChatViewController(chatType: .thread(threadId: threadId))
                self.navigationController?.pushViewController(vc, animated: true)
                self.threadCreatedHandle?()
            }
        }
    }
}

extension ThreadCreateViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.textField {
            if let text = textField.text, text.count > 0 {
                self.chatInputView.isUserInteractionEnabled = true
                self.chatInputView.alpha = 1
                self.chatInputView.becomeFirstResponder()
            } else {
                self.chatInputView.isUserInteractionEnabled = false
                self.chatInputView.alpha = 0.6
            }
        }
        return true
    }
}

extension ThreadCreateViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let firstUrl = urls.first else {
            return
        }
        if !firstUrl.startAccessingSecurityScopedResource() {
            return
        }
        let fileCoordinator = NSFileCoordinator()
        fileCoordinator.coordinate(readingItemAt: firstUrl, error: nil) { url in
            if let data = try? Data(contentsOf: url) {
                let body = EMFileMessageBody(data: data, displayName: url.lastPathComponent)
                self.createAction(messageBody: body)
                firstUrl.stopAccessingSecurityScopedResource()
            }
        }
    }
}

extension ThreadCreateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage, let imageData = image.jpegData(compressionQuality: 1) {
            let body = EMImageMessageBody(data: imageData, displayName: nil)
            body.size = image.size
            self.createAction(messageBody: body)
        }
        picker.dismiss(animated: true)
    }
}
