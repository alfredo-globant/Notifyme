//
//  AppDelegate.swift
//  NotificationsExample
//
//  Created by Jesus2 HERNANDEZ on 9/20/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import UIKit
import Notifications
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var notificationsManager: UserNotificationManager? {
        return (window?.rootViewController as? MainViewController)?.notificationsManager
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        _ = window?.rootViewController?.view
        UNUserNotificationCenter.current().delegate = notificationsManager?.designatedDelegate()
        
        if #available(iOS 10, *) {
            application.registerForRemoteNotifications()
        }
        return true
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("AppDelegate> application: didFailToRegisterForRemoteNotificationsWithError")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
       print("AppDelegate> application: didRegisterForRemoteNotificationsWithDeviceToken")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("AppDelegate> application: didReceiveRemoteNotification")
        notificationsManager?.didReceiveNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
}
