//
//  UserNotificationReceivableTests.swift
//  NotificationsTests
//
//  Created by Ben RIAZY on 16/02/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import Foundation
import XCTest
@testable import Notifications
import UserNotifications

class UserNotificationReceivableTests: XCTestCase {
    
    private var subject: UserNotificationManager!
    
    private let mockAuthorizationManager = MockUserNotificationAuthorizationManager(status: .authorized, shouldAuthorize: true)
    private let mockHost = MockUserNotificationHost(userNotificationsAreEnabled: true)
    private let mockNotificationResolver = MockNotificationResolver()
    private let firstMockReceivable = FirstMockPushNotificationFeatureReceivable()
    private let secondMockReceivable = SecondMockPushNotificationFeatureReceivable()
    
    override func setUp() {
        super.setUp()
        mockNotificationResolver.receivers = [firstMockReceivable, secondMockReceivable]
        subject = UserNotificationManager(host: mockHost,
                                          authorizationManager: mockAuthorizationManager,
                                          notificationResolver: mockNotificationResolver)
    }
    
    override func tearDown() {
        subject = nil
        super.tearDown()
    }
    
    func testReceivingAPNSToken() {
        guard let mockNotificationData = "Some-random-string-data".data(using: .utf8) else {
            return XCTFail()
        }
        
        // If I set the APNS Token
        subject.setAPNSToken(mockNotificationData)
        
        // Then that token should be cached
        XCTAssertNotNil(subject.cachedAPNSToken)
        // And sent to a newly registered feature
        XCTAssertNotNil(firstMockReceivable.receivedAPNSToken)
        XCTAssertEqual(firstMockReceivable.receivedAPNSToken, mockNotificationData)
    }
    
    func testRegisterReceivableType() throws {
        let mockReceivable = ThirdMockPushNotificationFeatureReceivable()
        
        try subject.registerReceiver(mockReceivable)
        
        // Then its part of the registered receivables
        XCTAssert(mockNotificationResolver.receivers.contains { $0.identifier == mockReceivable.identifier })
    }
    
    func testDidAssociateIsCalledForRegisteredReceivers() {
        subject.didGainMinimumAuthenticationLevel()
        
        XCTAssertTrue(firstMockReceivable.tokenDidAssociate)
        XCTAssertTrue(secondMockReceivable.tokenDidAssociate)
    }
    
    func testDidDissociateIsCalledForRegisteredReceivers() {
        subject.didRemoveMinimumAuthenticationLevel()
        
        XCTAssertTrue(firstMockReceivable.tokenDidDisassociate)
        XCTAssertTrue(secondMockReceivable.tokenDidDisassociate)
    }
    
    func testFailsToRegisterDuplicateReceivableType() {
        let mockAlreadyRegisteredReceivable = FirstMockPushNotificationFeatureReceivable()
        
        XCTAssertThrowsError(try subject.registerReceiver(mockAlreadyRegisteredReceivable))
    }
    
    func testDidReceiveNotification() throws {
        mockNotificationResolver.stubbedReceiverForPayload = firstMockReceivable

        // And I send a notification to one of the registered receivers
        subject.didReceiveNotification(userInfo: firstMockRawPayload) { _ in }
        
        // Then the dedicated receiver should have received the notification
        let encodedRawMockPayload = try JSONSerialization.data(withJSONObject: firstMockRawPayload, options: [])
        let expectedReceivedPushNotification = try JSONDecoder().decode(FirstMockNotification.self, from: encodedRawMockPayload)
        
        XCTAssertEqual(firstMockReceivable.receivedPushNotification.type, expectedReceivedPushNotification.type)
        
        // And none of the other receivers should have received the notification
        XCTAssertNil(secondMockReceivable.receivedPushNotification)
    }
    
    func testDidReceiveNotificationCallsCompletionWithNoDataIfNotReciverExists() {
        var capturedResult: UIBackgroundFetchResult!
        
        subject.didReceiveNotification(userInfo: firstMockRawPayload) { result in
            capturedResult = result
        }
        
        XCTAssertEqual(capturedResult, .noData)
    }
    
    func testWillPresentNotification() throws {
        mockNotificationResolver.stubbedReceiverForPayload = firstMockReceivable

        // And I send a notification to one of the registered receivers
        subject.willPresentNotification(firstMockRawPayload) { _ in }
        
        // Then the dedicated receiver should have received the notification
        let encodedRawMockPayload = try JSONSerialization.data(withJSONObject: firstMockRawPayload, options: [])
        let expectedReceivedPushNotification = try JSONDecoder().decode(FirstMockNotification.self, from: encodedRawMockPayload)
        
        XCTAssertEqual(firstMockReceivable.capturedWillPresentNotification.type, expectedReceivedPushNotification.type)
        
        // And none of the other receivers should have received the notification
        XCTAssertNil(secondMockReceivable.capturedWillPresentNotification)
    }
    
    func testWillPresentNotificationCallsCompletionWithNoOptionsIfNotReciverExists() {
        var capturedOptions: UNNotificationPresentationOptions!
        
        subject.willPresentNotification(firstMockRawPayload) { options in
            capturedOptions = options
        }
        
        XCTAssertEqual(capturedOptions, [])
    }
}
