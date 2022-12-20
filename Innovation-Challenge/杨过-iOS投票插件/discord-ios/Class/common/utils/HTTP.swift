//
//  HTTP.swift
//  discord-ios
//
//  Created by 冯钊 on 2022/7/28.
//

import UIKit
import HyphenateChat

class HTTP: NSObject {
    
    class var baseUrlWithAppKey: String? {
        var baseUrl: String?
//        if EMClient.shared().options.enableDnsConfig {
            baseUrl = "a1.easemob.com"
//        } else {
//            baseUrl = EMClient.shared().options.restServer
//        }
        guard var baseUrl = baseUrl, let appkey = EMClient.shared().options.appkey else {
            return nil
        }
        baseUrl += "/"
        baseUrl += appkey.replacingOccurrences(of: "#", with: "/")
        return baseUrl
    }
    
    class func uploadImage(image: UIImage, completionHandler: ((_ path: String?, _ error: Error?) -> Void)?) {
        guard let baseUrl = self.baseUrlWithAppKey else {
            return
        }
        guard let url = URL(string: "https://\(baseUrl)/chatfiles") else {
            return
        }
        guard let data = image.jpegData(compressionQuality: 1) else {
            return
        }
        let boundary = String(format: "Boundary+%08X%08X", arc4random(), arc4random())
        var body = Data()
        body.append("--\(boundary)\r\nContent-Disposition: form-data; name=\"file\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let token = EMClient.shared().accessUserToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("true", forHTTPHeaderField: "restrict-access")
        request.setValue(boundary, forHTTPHeaderField: "boundary")
        request.setValue("\(body.count)", forHTTPHeaderField: "Content-Length")
        
        let task = URLSession.shared.uploadTask(with: request, from: body) { data, _, error in
            if let data = data {
                if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let url = obj["uri"] as? String, let uuid = ((obj["entities"] as? [Any])?.first as? [String: Any])?["uuid"] as? String {
                        DispatchQueue.main.async {
                            completionHandler?(url + "/" + uuid, nil)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler?(nil, error)
                }
            }
        }
        task.resume()
    }
}
