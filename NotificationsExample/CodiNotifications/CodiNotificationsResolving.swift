//
//  CodiNotificationsResolving.swift
//  NotificationsExample
//
//  Created by Jesus2 HERNANDEZ on 9/20/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import Foundation
import Notifications

class CodiNotificationResolving: NotificationResolving {
    
    init() { }
    
    var receivers: [NotificationReceivable] = [CodiNotificationReceivable()]
    
    func receiver(for payload: [AnyHashable : Any]) -> NotificationReceivable? {
        return nil
    }
}
