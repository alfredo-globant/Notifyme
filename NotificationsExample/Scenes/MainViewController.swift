//
//  ViewController.swift
//  NotificationsExample
//
//  Created by Jesus2 HERNANDEZ on 9/20/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import UIKit
import Notifications
import UserNotifications

class MainViewController: UIViewController {
    
    var notificationsManager: UserNotificationManager?
    var receivers: [NotificationReceivable] = [CodiNotificationReceivable()]

    override func viewDidLoad() {
        super.viewDidLoad()
        //notificationsManager = UserNotificationManager(requesting: [.badge, .alert, .sound], host: self, notificationResolver: receivers)
    }
}


extension MainViewController: UserNotificationHost {
    var userNotificationsAreEnabled: Bool {
        return true
    }
}
