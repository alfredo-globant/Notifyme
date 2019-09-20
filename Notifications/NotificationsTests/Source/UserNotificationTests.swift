//
//  UserNotificationTests.swift
//  NotificationsTests
//
//  Created by Ben RIAZY on 19/02/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import Foundation
import XCTest
@testable import Notifications
import UserNotifications

struct MockUserNotificationHost: UserNotificationHost {
    
    var userNotificationsAreEnabled: Bool
    
}

struct MockUserNotificationAuthorizationManager: UserNotificationAuthorizationManaging {
    
    var status: UNAuthorizationStatus
    var shouldAuthorize: Bool
    
    func requestAuthorization(completionHandler: @escaping (Bool) -> Void) {
        completionHandler(shouldAuthorize)
    }
    
    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        completionHandler(status)
    }
    
}

class MockNotificationReceiver: NotificationReceivable {    
    func decode(_ userInfo: [AnyHashable : Any]) -> Decodable? { return nil }
    func didReceive(apnsToken: Data) {}
    func associateToken() {}
    func disassociateToken() {}
    func didReceiveNotification(_ payload: Decodable, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {}
    func willPresentNotification(_ payload: Decodable, presentationOptions completion: ((UNNotificationPresentationOptions) -> Void)?) {}}

class UserNotificationTests: XCTestCase {

    var subject: UserNotificationManager!
    var mockMotificationResolver: MockNotificationResolver!
    
    override func setUp() {
        super.setUp()
        let host = MockUserNotificationHost(userNotificationsAreEnabled: true)
        let mockAuthorizationManager = MockUserNotificationAuthorizationManager(status: .authorized, shouldAuthorize: true)
        mockMotificationResolver = MockNotificationResolver()
        subject =  UserNotificationManager(host: host, authorizationManager: mockAuthorizationManager, notificationResolver: mockMotificationResolver)
    }
    
    override func tearDown() {
        subject = nil
        mockMotificationResolver = nil
        super.tearDown()
    }
    
    func testItCanRegisterANotificationReceiver() throws {
        let mockNotificationReceiver = MockNotificationReceiver()
        
        try subject.registerReceiver(mockNotificationReceiver)
        
        XCTAssert(mockMotificationResolver.receivers.first as AnyObject === mockNotificationReceiver as AnyObject)
    }
    
    func testItDoesNotRegisterANotificationReceiverThatIsAlreadyRegistered() throws {
        let mockNotificationReceiverA = MockNotificationReceiver()
        let mockNotificationReceiverB = MockNotificationReceiver()

        try subject.registerReceiver(mockNotificationReceiverA)
        do {
            try subject.registerReceiver(mockNotificationReceiverB)
        } catch {
            guard case UserNotificationManagerError.receiverAlreadyRegister = error else {
                return XCTFail("Wrong error throw, \(error)")
            }
        }
        mockMotificationResolver.receivers.forEach { receiver in
            XCTAssert(receiver as AnyObject !== mockNotificationReceiverB as AnyObject)
        }
    }
}

