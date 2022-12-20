//
//  AppDelegate.swift
//  Fish
//
//  Created by 石玉龙 on 2022/12/7.
//

import UIKit
import CoreData
import Bugly
import HyphenateChat

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Bugly.start(withAppId: "")
        
        let emOptions = EMOptions(appkey: "1185170212115891#fish")
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
    
    // MARK: - public
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Fish")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

