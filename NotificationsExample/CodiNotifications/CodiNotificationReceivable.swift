//
//  CodiNotificationReceivable.swift
//  NotificationsExample
//
//  Created by Jesus2 HERNANDEZ on 9/20/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import Foundation
import Notifications
import UserNotifications

class CodiNotificationReceivable: NotificationReceivable {
    var isAssociated: Bool?
    var apnsTokenData: Data?
    
    func decode(_ userInfo: [AnyHashable : Any]) -> Decodable? {
        // Decode notification
        return nil
    }
    
    func didReceive(apnsToken: Data) {
        self.apnsTokenData = apnsToken
    }
    
    func associateToken() { isAssociated = true }
    
    func disassociateToken() { isAssociated = false }
    
    func didReceiveNotification(_ payload: Decodable, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    }
    
    func willPresentNotification(_ payload: Decodable, presentationOptions completion: ((UNNotificationPresentationOptions) -> Void)?) {
        
    }
}
