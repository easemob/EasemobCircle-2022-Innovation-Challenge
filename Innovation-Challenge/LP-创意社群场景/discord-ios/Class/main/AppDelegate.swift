//
//  AppDelegate.swift
//  circle-ios
//
//  Created by 冯钊 on 2022/6/7.
//

import UIKit
import HyphenateChat
import Bugly

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Bugly.start(withAppId: "")
        
        let emOptions = EMOptions(appkey: "540933120#discard-ios-demo")
        #if DEBUG
        emOptions.enableConsoleLog = true
        #else
        emOptions.enableConsoleLog = false
        #endif
        emOptions.isAutoLogin = true
        EMClient.shared().initializeSDK(with: emOptions)
        
        UITextField.appearance().tintColor = UIColor(named: ColorName_27AE60)
        UITextView.appearance().tintColor = UIColor(named: ColorName_27AE60)
        
        self.window = UIWindow()
        if EMClient.shared().isLoggedIn {
            self.switchToMain()
        } else {
            self.switchToLogin()
        }
        self.window?.makeKeyAndVisible()
        UserOnlineManager.shared.addDelete()
        ServerRoleManager.shared.addDelete()
        return true
    }

    public func switchToMain() {
        let mainVc = MainViewController()
        self.window?.rootViewController = mainVc
        if let userId = EMClient.shared().currentUsername {
            Bugly.setUserIdentifier(userId)
        }
    }
    public func switchToLogin() {
        let vc = LoginViewController()
        self.window?.rootViewController = vc
    }
}
