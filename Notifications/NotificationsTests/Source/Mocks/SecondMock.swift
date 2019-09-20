//
//  SecondMock.swift
//  NotificationsTests
//
//  Created by Ben RIAZY on 19/02/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import Foundation
import Notifications
import UserNotifications
import UIKit

class SecondMockNotification: Decodable {
    var amount: Int
}

class SecondMockPushNotificationFeatureReceivable: NotificationReceivable, PayloadDecoder {
    
    typealias PayloadType = SecondMockNotification
    var decodableType: SecondMockNotification.Type = SecondMockNotification.self

    var receivedAPNSToken: Data?
    var receivedPushNotification: SecondMockNotification?
    var capturedWillPresentNotification: SecondMockNotification?

    var tokenDidAssociate: Bool!
    var tokenDidDisassociate: Bool!
    
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
        receivedPushNotification = payload as? SecondMockNotification
    }
    
    func willPresentNotification(_ payload: Decodable, presentationOptions completion: ((UNNotificationPresentationOptions) -> Void)?) {
        capturedWillPresentNotification = payload as? SecondMockNotification
    }
    
    static func ==(lhs: SecondMockPushNotificationFeatureReceivable, rhs: SecondMockPushNotificationFeatureReceivable) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var hashValue: Int {
        return self.identifier.hashValue
    }
    
}

let secondMockRawPayload: [AnyHashable: Any] = ["amount": 22]
