//
//  Photo.swift
//  Yellow
//
//  Created by Icey.Liao on 2022/12/17.
//

import Foundation
import UIKit
import InputBarAccessoryView

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @objc
  func showImagePickerControllerActionSheet() {
      let photoLibraryAction = UIAlertAction(title: "从相册中选取", style: .default) { [weak self] _ in
          self?.showImagePickerController(sourceType: .photoLibrary)
        }

      let cameraAction = UIAlertAction(title: "拍摄", style: .default) { [weak self] _ in
          self?.showImagePickerController(sourceType: .camera)
        }

      let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)

      let ac = UIAlertController(title: "选择照片", message: nil, preferredStyle: .actionSheet)
      ac.addAction(photoLibraryAction)
      ac.addAction(cameraAction)
      ac.addAction(cancelAction)
      
      self.present(ac, animated: true)
  }

  func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
      let imgPicker = UIImagePickerController()
      imgPicker.delegate = self
      imgPicker.allowsEditing = true
      imgPicker.sourceType = sourceType
      
      inputAccessoryView?.isHidden = true
      present(imgPicker, animated: true, completion: nil)
  }

  func imagePickerController(
    _: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any])
  {
    if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
      // self.sendImageMessage(photo: editedImage)
        messageInputBar.inputPlugins.forEach { _ = $0.handleInput(of: editedImage) }
    }
    else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        messageInputBar.inputPlugins.forEach { _ = $0.handleInput(of: originImage) }
      // self.sendImageMessage(photo: originImage)
    }
    dismiss(animated: true, completion: nil)
    inputAccessoryView?.isHidden = false
  }

  func imagePickerControllerDidCancel(_: UIImagePickerController) {
    dismiss(animated: true, completion: nil)
    inputAccessoryView?.isHidden = false
  }
    
}

// MARK: AttachmentManagerDelegate

extension ChatViewController: AttachmentManagerDelegate {
  // MARK: - AttachmentManagerDelegate

  func attachmentManager(_: AttachmentManager, shouldBecomeVisible: Bool) {
      setAttachmentManager(active: shouldBecomeVisible)
  }

  func attachmentManager(_ manager: AttachmentManager, didReloadTo _: [AttachmentManager.Attachment]) {
      messageInputBar.sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_ manager: AttachmentManager, didInsert _: AttachmentManager.Attachment, at _: Int) {
      messageInputBar.sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_ manager: AttachmentManager, didRemove _: AttachmentManager.Attachment, at _: Int) {
      messageInputBar.sendButton.isEnabled = manager.attachments.count > 0
  }

  func attachmentManager(_: AttachmentManager, didSelectAddAttachmentAt _: Int) {
    showImagePickerControllerActionSheet()
  }

  // MARK: - AttachmentManagerDelegate Helper

  func setAttachmentManager(active: Bool) {
      let topStackView = messageInputBar.topStackView
    if active, !topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
      topStackView.insertArrangedSubview(attachmentManager.attachmentView, at: topStackView.arrangedSubviews.count)
      topStackView.layoutIfNeeded()
    } else if !active, topStackView.arrangedSubviews.contains(attachmentManager.attachmentView) {
      topStackView.removeArrangedSubview(attachmentManager.attachmentView)
      topStackView.layoutIfNeeded()
    }
  }
}
