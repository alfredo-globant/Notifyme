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
import AppController

@UIApplicationMain
class AppDelegate: AppControllingDelegate {

//    var window: UIWindow?
//
//    var notificationsManager: UserNotificationManager?
//
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
//        // Override point for customization after application launch.
//
//        UNUserNotificationCenter.current().delegate = notificationsManager?.designatedDelegate()
//        return true
//    }
    
    override func makeAppController() throws -> AppController {
        let initialController = WrappingAppController()
        return initialController
    }
    
}

