import Foundation
import UserNotifications
import FirebaseCore

protocol UserNotificationAuthorizationManaging {
    
    func requestAuthorization(completionHandler: @escaping (Bool) -> Void)
    
    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void)
    
}

final class UserNotificationAuthorizationManager: UserNotificationAuthorizationManaging {
    
    private let requestedOptions: UNAuthorizationOptions
    private let provider: UserNotificationAuthorizationProviding
    
    init(requesting requestedOptions: UNAuthorizationOptions, provider: UserNotificationAuthorizationProviding = UNUserNotificationCenter.current()) {
        self.requestedOptions = requestedOptions
        self.provider = provider
    }
    
    func requestAuthorization(completionHandler: @escaping (Bool) -> Void) {
        provider.requestAuthorization(options: requestedOptions) { isAuthorized, _ in
            completionHandler(isAuthorized)
        }
    }
    
    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        provider.getAuthorizationStatus {
            completionHandler($0)
        }
    }
    
}
