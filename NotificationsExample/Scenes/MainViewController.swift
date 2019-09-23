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

// MARK: - Main View Controller

class MainViewController: UIViewController {
    var notificationsManager: UserNotificationManager?
    var notificationResolver: NotificationResolving = CodiNotificationResolving()
    var areNotificationsEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationsManager = UserNotificationManager(requesting: [.badge, .alert, .sound],
                                                       host: self,
                                                       notificationResolver: notificationResolver)
        
        notificationsManager?.delegate = self
        
        notificationsManager?.requestAuthorization { authResponse in
            print("MainViewController> viewDidLoad: Is authorised?: \(authResponse.isAuthorised)")
            self.areNotificationsEnabled = authResponse.isAuthorised
        }
    }
    
    func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Hello, World!"
        content.body = "Sample notification"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 20, repeats: false)
        let identifier = "MyNotification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            print("MainViewController> createNotification: Error in notification was \(error)")
        }
    }
    
    
    @IBAction func createLocalNotification(_ sender: UIButton) {
        createNotification()
    }
    
    // FirebaseAppDelegateProxyEnabled
    @IBAction func configureFirebase(_ sender: Any) {
        notificationsManager?.configureFirebase()
        notificationsManager?.getFirebaseToken(completion: { (token) in
            debugPrint("Token: \(token ?? "error getting token")")
        })
    }
    
    @IBAction func configureWithOptions(_ sender: UIButton) {

        let googleID = "352548351493"
        let iOSID = "5aedc52956b22d68917884"
        notificationsManager?.configureFirebaseOptions(googleID: googleID, iOSID: iOSID, completionHandler: { result in
            debugPrint(result)
        })
        self.notificationsManager?.getFirebaseToken(completion: { token in
            debugPrint("Token: \(token ?? "error getting token")")
        })
    }
    
    @IBAction func getToken(_ sender: UIButton) {
        notificationsManager?.getFirebaseToken(completion: { token in
            debugPrint("Token: \(token ?? "error getting token")")
        })
    }
    
}

// MARK: - User notifications host

extension MainViewController: UserNotificationHost {
    var userNotificationsAreEnabled: Bool {
        return areNotificationsEnabled
    }
}

extension MainViewController: UserNotificationManagerDelegate {
    
    func userNotificationManager(_ userNotificationManager: UserNotificationManager, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("MainViewController> userNotificationManager: \(response.notification.request.content.title)")
        completionHandler()
    }
    
    
    
}
