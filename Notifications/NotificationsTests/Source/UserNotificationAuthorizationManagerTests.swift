import XCTest
import UserNotifications
@testable import Notifications

private final class MockUserNotificationAuthorizationProvider: UserNotificationAuthorizationProviding {
    
    var currentAuthorizationStatus: UNAuthorizationStatus
    
    init(currentAuthorizationStatus: UNAuthorizationStatus) {
        self.currentAuthorizationStatus = currentAuthorizationStatus
    }
    
    var optionsAskedToAuthorize: UNAuthorizationOptions?
    var callback: ((Bool, Error?) -> Void)?
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        optionsAskedToAuthorize = options
        callback = completionHandler
    }
    
    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        completionHandler(currentAuthorizationStatus)
    }

}

class UserNotificationAuthorizationManagerTests: XCTestCase {
    
    func testAuthorizing() {
        let provider = MockUserNotificationAuthorizationProvider(currentAuthorizationStatus: .notDetermined)
        let manager = UserNotificationAuthorizationManager(requesting: [.alert, .badge], provider: provider)
        
        var callbackCount = 0
        manager.requestAuthorization { isAuthorized in
            XCTAssertTrue(isAuthorized)
            callbackCount += 1
        }
        
        guard let options = provider.optionsAskedToAuthorize, let callback = provider.callback else {
            XCTFail("Did not request options to be authorized")
            return
        }
        
        XCTAssertEqual(options, [.alert, .badge])
        
        XCTAssertEqual(callbackCount, 0)
        callback(true, nil)
        XCTAssertEqual(callbackCount, 1)
    }
    
    func testDenying() {
        let provider = MockUserNotificationAuthorizationProvider(currentAuthorizationStatus: .notDetermined)
        let manager = UserNotificationAuthorizationManager(requesting: [.alert, .sound], provider: provider)
        
        var callbackCount = 0
        manager.requestAuthorization { isAuthorized in
            XCTAssertFalse(isAuthorized)
            callbackCount += 1
        }
        
        guard let options = provider.optionsAskedToAuthorize, let callback = provider.callback else {
            XCTFail("Did not request options to be authorized")
            return
        }
        
        XCTAssertEqual(options, [.alert, .sound])
        
        XCTAssertEqual(callbackCount, 0)
        callback(false, nil)
        XCTAssertEqual(callbackCount, 1)
    }
    
    func testGettingStatusWhenAuthorized() {
        let requestedOptions: UNAuthorizationOptions = [.alert, .badge]
        let provider = MockUserNotificationAuthorizationProvider(currentAuthorizationStatus: .authorized)

        let manager = UserNotificationAuthorizationManager(requesting: requestedOptions, provider: provider)

        expectSyncCallback { fulfill in
            manager.getAuthorizationStatus { status in
                XCTAssertEqual(status, .authorized)
                fulfill()
            }
        }
    }
    
    func testGettingStatusWhenNotDetermined() {
        let requestedOptions: UNAuthorizationOptions = [.alert, .badge]
        let provider = MockUserNotificationAuthorizationProvider(currentAuthorizationStatus: .notDetermined)
        
        let manager = UserNotificationAuthorizationManager(requesting: requestedOptions, provider: provider)
        
        expectSyncCallback { fulfill in
            manager.getAuthorizationStatus { status in
                XCTAssertEqual(status, .notDetermined)
                fulfill()
            }
        }
    }
    
    func testGettingStatusWhenDenied() {
        let requestedOptions: UNAuthorizationOptions = [.alert, .badge]
        let provider = MockUserNotificationAuthorizationProvider(currentAuthorizationStatus: .denied)
        
        let manager = UserNotificationAuthorizationManager(requesting: requestedOptions, provider: provider)
        
        expectSyncCallback { fulfill in
            manager.getAuthorizationStatus { status in
                XCTAssertEqual(status, .denied)
                fulfill()
            }
        }
    }

}

