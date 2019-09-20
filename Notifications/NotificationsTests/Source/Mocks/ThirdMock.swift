//
//  ThirdMock.swift
//  NotificationsTests
//
//  Created by Ben RIAZY on 20/02/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import Foundation
import Notifications
import UserNotifications
import UIKit

class ThirdMockNotification: Decodable {
    var type: String
    var age: Int
    var height: String
}

class ThirdMockPushNotificationFeatureReceivable: NotificationReceivable, PayloadDecoder {
    
    typealias PayloadType = ThirdMockNotification
    var decodableType: ThirdMockNotification.Type = ThirdMockNotification.self
    
    var receivedAPNSToken: Data?
    var receivedPushNotification: ThirdMockNotification?
    var capturedWillPresentNotification: ThirdMockNotification?

    var tokenDidAssociate: Bool?
    var tokenDidDisassociate: Bool?
    
    func didReceive(apnsToken: Data) {
        receivedAPNSToken = apnsToken
    }
    
    func associateToken() {
        tokenDidAssociate = true
    }
    
    func disassociateToken() {
        tokenDidDisassociate = true
    }
    
    func didReceiveNotification(_ payload: Decodable, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        receivedPushNotification = payload as? ThirdMockNotification
    }
    
    func willPresentNotification(_ payload: Decodable, presentationOptions completion: ((UNNotificationPresentationOptions) -> Void)?) {
        capturedWillPresentNotification = payload as? ThirdMockNotification
    }
    
    static func ==(lhs: ThirdMockPushNotificationFeatureReceivable, rhs: ThirdMockPushNotificationFeatureReceivable) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var hashValue: Int {
        return self.identifier.hashValue
    }
    
}

