//
//  CodiNotificationResolver.swift
//  NotificationsExample
//
//  Created by Jair Moreno Gaspar on 9/30/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import Foundation
import Notifications

final class CodiNotificationResolver: NotificationResolving {
    var receivers: [NotificationReceivable] = [CodiNotificationReceivable()]
    
    func receiver(for payload: [AnyHashable : Any]) -> NotificationReceivable? {
        debugPrint("receiver")
        return nil
    }
    
    
}
