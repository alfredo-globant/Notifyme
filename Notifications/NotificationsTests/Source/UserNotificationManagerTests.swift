import XCTest
@testable import Notifications
import UserNotifications

class UserNotificationManagerTests: XCTestCase {
    
    // MARK: Status
    
    func testGettingAuthorizationStatusWhenEnabledByHost() {
        let host = MockUserNotificationHost(userNotificationsAreEnabled: true)
        let expectations = zip(
            [UNAuthorizationStatus.authorized, .notDetermined, .denied],
            [UserNotificationManager.AuthorizationStatus.authorized, .notDetermined, .deniedByUser]
        )
        for expectation in expectations {
            let authorizationManager = MockUserNotificationAuthorizationManager(status: expectation.0, shouldAuthorize: false)
            
            let manager = UserNotificationManager(host: host, authorizationManager: authorizationManager, notificationResolver: MockNotificationResolver())
            
            expectSyncCallback { fulfill in
                manager.getAuthorizationStatus { provided in
                    XCTAssertEqual(provided, expectation.1)
                    fulfill()
                }
            }
        }
    }
    
    func testGettingAuthorizationStatusWhenDisabledByHost() {
        let host = MockUserNotificationHost(userNotificationsAreEnabled: false)
        for expectedStatus in [UNAuthorizationStatus.authorized, .notDetermined, .denied] {
            let authorizationManager = MockUserNotificationAuthorizationManager(status: expectedStatus, shouldAuthorize: false)
            
            let manager = UserNotificationManager(host: host, authorizationManager: authorizationManager, notificationResolver: MockNotificationResolver())
            
            expectSyncCallback { fulfill in
                manager.getAuthorizationStatus { status in
                    XCTAssertEqual(status, .disabledByHost)
                    fulfill()
                }
            }
        }
    }
    
    // MARK: Authorization
    
    func testAskingForAuthorizationWhenDisabledByHost() {
        let host = MockUserNotificationHost(userNotificationsAreEnabled: false)
        let authorizationManager = MockUserNotificationAuthorizationManager(status: .notDetermined, shouldAuthorize: true)
        
        let manager = UserNotificationManager(host: host, authorizationManager: authorizationManager, notificationResolver: MockNotificationResolver())
        
        expectSyncCallback { fulfill in
            manager.requestAuthorization { response in
                XCTAssertEqual(response.resolutionMethod, .previouslyDetermined)
                XCTAssertFalse(response.isAuthorised)
                fulfill()
            }
        }
    }
    
    func testAskingForAuthorizationWhenNotDetermined() {
        let host = MockUserNotificationHost(userNotificationsAreEnabled: true)
        for shouldAllow in [true, false] {
            let authorizationManager = MockUserNotificationAuthorizationManager(status: .notDetermined, shouldAuthorize: shouldAllow)
            
            let manager = UserNotificationManager(host: host, authorizationManager: authorizationManager, notificationResolver: MockNotificationResolver())
            
            expectSyncCallback { fulfill in
                manager.requestAuthorization { response in
                    XCTAssertEqual(response.resolutionMethod, .askedUser)
                    XCTAssertEqual(response.isAuthorised, shouldAllow)
                    fulfill()
                }
            }
        }
    }
    
    func testAskingForAuthorizationWhenAlreadyDetermined() {
        let host = MockUserNotificationHost(userNotificationsAreEnabled: true)
        let expectations = zip(
            [UNAuthorizationStatus.authorized, .denied],
            [true, false]
        )
        for expectation in expectations {
            let authorizationManager = MockUserNotificationAuthorizationManager(status: expectation.0, shouldAuthorize: !expectation.1)
            
            let manager = UserNotificationManager(host: host, authorizationManager: authorizationManager, notificationResolver: MockNotificationResolver())
            
            expectSyncCallback { fulfill in
                manager.requestAuthorization { response in
                    XCTAssertEqual(response.resolutionMethod, .previouslyDetermined)
                    XCTAssertEqual(response.isAuthorised, expectation.1)
                    fulfill()
                }
            }
        }
    }
    
}
