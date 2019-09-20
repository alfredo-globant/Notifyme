//
//  UserNotificationManageable.swift
//  Notifications
//
//  Created by Ben RIAZY on 09/03/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import FirebaseCore

/// Protocol that defines the ability to receive an APNS Token and receive a push notification userInfo dictionary
public protocol UserNotificationManageable {

    /// Delegate used for communicating events from UserNotificationManager
    var delegate: UserNotificationManagerDelegate? { get set }

    /// This should be called by the host app to distribute the Token to all frameworks associated with Push Notification capabilities
    ///
    /// - Parameter token: The APNS Token from the host app
    func setAPNSToken(_ token: Data)
    
    /// Tells the feature that a remote notification for this feature arrived that indicates there is data to be fetched.
    ///
    /// Mimics [application(_:didReceiveRemoteNotification:fetchCompletionHandler:)]( https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1623013-application)
    ///
    /// - Parameters:
    ///   - userInfo: The raw payload from the notification
    ///   - fetchCompletionHandler: The closure to execute when the download operation is complete. Must be called as soon as possible.
    func didReceiveNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    
    /// Requests authorization to enable user notifications.
    ///
    /// - Parameter completionHandler: The block to execute asynchronously with the results. This block may be executed on a background thread.
    func requestAuthorization(completionHandler: @escaping (UserNotificationManager.AuthorizationResponse) -> Void)
    
    /// Requests the notification settings for this app.
    ///
    /// - important:
    /// On iOS 9, it is not possible to distinguish between `.notDetermined` and `.deniedByUser` statuses.
    /// In this situation, the receiver returns `.notDetermined`.
    ///
    /// - Parameter completionHandler: The block to execute asynchronously with the results. This block may be executed on a background thread.
    func getAuthorizationStatus(completionHandler: @escaping (UserNotificationManager.AuthorizationStatus) -> Void)
    
    /// The designated delegate to receive foreground Push Notifications on iOS 10 and newer
    ///
    /// - Returns: an object conforming the UNUserNotificationCenterDelegate
    func designatedDelegate() -> UNUserNotificationCenterDelegate?
    
    /// Registers a NotificationReceivable, if the receiver is already registered it is ignored
    ///
    /// - Parameter receiver: The receiver to register
    /// - Throws: Throws if the receiver is already registered
    func registerReceiver(_ receiver: NotificationReceivable) throws
    
    func configureFirebase(with options: FirebaseOptions?, completionHandler: @escaping (Bool) -> Void)
    
    func getFirebaseToken(completion: @escaping(String?) -> Void)
    
}
