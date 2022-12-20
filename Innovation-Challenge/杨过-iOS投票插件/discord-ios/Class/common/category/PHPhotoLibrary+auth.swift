//
//  PHPhotoLibrary+auth.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/8/17.
//

import Foundation
import Photos
import UIKit

extension PHPhotoLibrary {
    class func request(_ handle: @escaping () -> Void) {
        var auth: PHAuthorizationStatus
        if #available(iOS 14, *) {
            auth = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            auth = PHPhotoLibrary.authorizationStatus()
        }
        
        if auth == .authorized {
            handle()
        } else if auth == .notDetermined {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            handle()
                        }
                    }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        DispatchQueue.main.async {
                            handle()
                        }
                    }
                }
            }
        } else {
            self.showOpen()
        }
    }
    
    class private func showOpen() {
        let vc = UIAlertController(title: "无法访问相册中的照片", message: "你已关闭照片访问权限，请前往设置手动开启", preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "取消", style: .cancel))
        vc.addAction(UIAlertAction(title: "前往开启", style: .default, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
    }
}
