//
//  AppDelegate.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/1/23.
//

import UIKit
import CoreData
import Firebase
import SwiftyStoreKit
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        let userID = Auth.auth().currentUser?.uid
        if userID ?? "" != "" {
            print("* user is valid, attempting to register for remote notifications")
            if #available(iOS 10.0, *) {
                // For iOS 10 display notification (sent via APNS)
                UNUserNotificationCenter.current().delegate = self
                
                let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: { _, _ in }
                )
            } else {
                let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                application.registerUserNotificationSettings(settings)
            }
            
            application.registerForRemoteNotifications()
        }
        Messaging.messaging().delegate = self
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            print("SWIFTYSTORE -- COMPLETETRANSACTIONS:")
                for purchase in purchases {
                    print(purchase)
//                    switch purchase.transaction.transactionState {
//                    case .purchased, .restored:
//                        if purchase.needsFinishTransaction {
//                            // Deliver content from server, then:
//                            SwiftyStoreKit.finishTransaction(purchase.transaction)
//                        }
//                        // Unlock content
//                    case .failed, .purchasing, .deferred:
//                        break // do nothing
//                    }
                }
            }
        return true
    }
    func application(application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        let userID = Auth.auth().currentUser?.uid
        if userID ?? "" != "" {
            setUserNotificationToken(token: fcmToken ?? "")
        }
        
    }
    func setUserNotificationToken(token: String) {
      guard let uid = Auth.auth().currentUser?.uid else { return }
      // uplaod to firestore /users/{uid}/fcmToken
        let db = Firestore.firestore()
        db.collection("FCMTokens").document(uid).setData(["fcmToken": token], merge: true)
        // subscribe to topics (order notifications and pack notifications)
        Messaging.messaging().subscribe(toTopic: "orderNotifications")
        Messaging.messaging().subscribe(toTopic: "packNotifications")
        
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AI_Pet_App")
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
    func updateAllViewControllers() {
        let rootVC = UIApplication.shared.windows.first?.rootViewController
        if let tabVC = rootVC as? UITabBarController {
            for vc in tabVC.viewControllers! {
                if let navVC = vc as? UINavigationController {
                    if let home = navVC.viewControllers.first as? ViewController {
                        home.updateUI()
                    }
                    if let search = navVC.viewControllers.first as? SearchViewController {
//                        search.updateUI()
                    }
                    if let profile = navVC.viewControllers.first as? OrdersViewController {
                        profile.updateUI()
                    }
                    if let settings = navVC.viewControllers.first as? SettingsViewController {
                        settings.updateUI()
                    }
                }
            }
        }
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // ...
        
        // Print full message.
        print("* WILL PRESENT NOTIFICATION:")
        print(userInfo)
        let state = UIApplication.shared.applicationState
        UIApplication.shared.applicationIconBadgeNumber += 1
        if state == .background || state == .inactive {
            // background
            
            completionHandler([[.alert, .sound]])
        } else if state == .active {
            // foreground -- show some sort of alert?
//            if let tab = UIApplication.tabBarController() as? mainTabBarController {
//                tab.shouldSetRedTing = true
//                tab.redNotificationsCircle?.fadeIn()
//            }
//            completionHandler(nil)
        }
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // ...
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print full message.
        print("* DID RECEIVE NOTIFICATION:")
        print(userInfo)
        let state = UIApplication.shared.applicationState
        if state == .background || state == .inactive {
            // background
            UIApplication.shared.applicationIconBadgeNumber += 1
        } else if state == .active {
            // foreground -- show some sort of alert?
        }

        
        completionHandler()
    }
}
@available(iOSApplicationExtension 10.0, *)
extension UNNotificationAttachment {
    
    static func saveImageToDisk(fileIdentifier: String, data: NSData, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let folderName = ProcessInfo.processInfo.globallyUniqueString
        let folderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(folderName, isDirectory: true)
        
        do {
            try fileManager.createDirectory(at: folderURL!, withIntermediateDirectories: true, attributes: nil)
            let fileURL = folderURL?.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL!, options: [])
            let attachment = try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL!, options: options)
            return attachment
        } catch let error {
            print("error \(error)")
        }
        
        return nil
    }
}
