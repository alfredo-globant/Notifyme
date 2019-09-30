//
//  WrappingAppController.swift
//  NotificationsExample
//
//  Created by Jair Moreno Gaspar on 9/30/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import Foundation
import AppController
import UserNotifications
import Notifications

class WrappingAppController: AppController {
    var viewController: UIViewController = ViewController()
    var notificationManager: UserNotificationManager? {
        return ViewController().notificationManager
    }
    
    init() {
        debugPrint("init")
        UNUserNotificationCenter.current().delegate = notificationManager?.designatedDelegate()
    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint("didReceive")
    }
    
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        debugPrint("didReceive deviceToken: \(deviceToken.hexString)")
    }
    
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}
