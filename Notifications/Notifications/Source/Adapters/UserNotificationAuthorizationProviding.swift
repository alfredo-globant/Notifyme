import UserNotifications

protocol UserNotificationAuthorizationProviding {
    
    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void)
    
    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void)
    
}

extension UNUserNotificationCenter: UserNotificationAuthorizationProviding {
    
    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        getNotificationSettings {
            completionHandler($0.authorizationStatus)
        }
    }
}
