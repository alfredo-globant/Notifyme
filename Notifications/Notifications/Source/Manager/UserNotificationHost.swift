//
//  UserNotificationHost.swift
//  Notifications
//
//  Created by Ben RIAZY on 09/03/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import Foundation

/// A type to represent the interests of the host (app) for notifications.
///
/// This is usually implemented by a host to provide decisions about push notifications.
public protocol UserNotificationHost {
    
    /// Returns `true` if host is allowing user notifications to be used; `false` otherwise.
    var userNotificationsAreEnabled: Bool { get }
    
}
