//
//  FirstMock.swift
//  NotificationsTests
//
//  Created by Ben RIAZY on 19/02/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import UIKit
import Notifications
import UserNotifications

struct FirstMockNotification: Decodable {
    var type: String
    var age: Int
    var hairColor: String
}

class FirstMockPushNotificationFeatureReceivable: NotificationReceivable, PayloadDecoder {
    
    typealias PayloadType = FirstMockNotification
    var decodableType: FirstMockNotification.Type = FirstMockNotification.self
    
    var receivedAPNSToken: Data?
    var receivedPushNotification: FirstMockNotification!
    var capturedWillPresentNotification: FirstMockNotification!

    var tokenDidAssociate: Bool!
    var tokenDidDisassociate: Bool!
    
    let mockViewController = UIViewController()
    
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
        receivedPushNotification = payload as? FirstMockNotification
    }
    
    func willPresentNotification(_ payload: Decodable, presentationOptions completion: ((UNNotificationPresentationOptions) -> Void)?) {
        capturedWillPresentNotification = payload as? FirstMockNotification
    }
    
}

extension FirstMockPushNotificationFeatureReceivable: Hashable {
    
    static func ==(lhs: FirstMockPushNotificationFeatureReceivable, rhs: FirstMockPushNotificationFeatureReceivable) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    var hashValue: Int {
        return self.identifier.hashValue
    }
    
}

let firstMockRawPayload: [AnyHashable: Any] = ["type": "Some Value",
    "age": 22,
    "hairColor": "Blue"
]

