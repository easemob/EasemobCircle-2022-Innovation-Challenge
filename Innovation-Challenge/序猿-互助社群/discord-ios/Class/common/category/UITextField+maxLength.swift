//
//  UITextField+maxLength.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/29.
//

import UIKit

private var Max_Length_Length = "max_length_length"
private var Max_Length_Block = "max_length_block"

extension UITextField {
    func setMaxLength(_ length: Int, lengthChange: ((_ length: Int) -> Void)?) {
        let lengthKey = withUnsafePointer(to: &Max_Length_Length) { UnsafeRawPointer($0) }
        objc_setAssociatedObject(self, lengthKey, length, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        let blockKey = withUnsafePointer(to: &Max_Length_Block) { UnsafeRawPointer($0) }
        objc_setAssociatedObject(self, blockKey, lengthChange, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        
        self.addTarget(self, action: #selector(maxLength_OnEditingChanged), for: .editingChanged)
    }
    
    @objc private func maxLength_OnEditingChanged() {
        let lengthKey = withUnsafePointer(to: &Max_Length_Length) { UnsafeRawPointer($0) }
        guard let maxLength = objc_getAssociatedObject(self, lengthKey) as? Int else { return }
        if self.markedTextRange != nil {
            return
        } else if let text = self.text, text.count > maxLength {
            self.text = String(text.prefix(maxLength))
        }
        let blockKey = withUnsafePointer(to: &Max_Length_Block) { UnsafeRawPointer($0) }
        if let block = objc_getAssociatedObject(self, blockKey) as? (_ length: Int) -> Void {
            block(self.text?.count ?? 0)
        }
    }
}
