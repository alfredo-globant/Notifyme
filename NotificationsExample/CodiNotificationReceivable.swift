//
//  CodiNotificationReceivable.swift
//  NotificationsExample
//
//  Created by Jair Moreno Gaspar on 9/30/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import Foundation
import Notifications
import UserNotifications

class CodiNotificationReceivable: NotificationReceivable {
    
    var isAssociatedToken: Bool?
    var apnsTokenData: Data?
    
    func decode(_ userInfo: [AnyHashable : Any]) -> Decodable? {
        debugPrint("Decode")
        return nil
    }
    
    func didReceive(apnsToken: Data) {
        self.apnsTokenData = apnsToken
    }
    
    func associateToken() {
        isAssociatedToken = true
    }
    
    func disassociateToken() {
        isAssociatedToken = false
    }
    
    func didReceiveNotification(_ payload: Decodable, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint("Didreceive")
    }
    
    func willPresentNotification(_ payload: Decodable, presentationOptions completion: ((UNNotificationPresentationOptions) -> Void)?) {
        debugPrint("willPresent")
    }
    
    
}
