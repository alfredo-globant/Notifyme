import UIKit
import UserNotifications
import FirebaseCore
import FirebaseInstanceID

fileprivate let notificationCenterDelegateContainer = NotificationCenterDelegateContainer()

enum UserNotificationManagerError: Error {
    case receiverAlreadyRegister
}

public protocol UserNotificationManagerDelegate: class {
    
    /// Asks the delegate to process the user's response to a delivered notification.
    ///
    /// Mimics [userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler:](https://developer.apple.com/documentation/usernotifications/unusernotificationcenterdelegate/1649501-usernotificationcenter)
    ///
    /// - Parameters:
    ///   - userNotificationManager: The userNotificationManager that sent this message
    ///   - response: The user’s response to the notification.
    ///   - completionHandler: The block to execute when you have finished processing the user’s response. You must execute this block at some point after processing the user's response to let the system know that you are done.
    func userNotificationManager(_ userNotificationManager: UserNotificationManager, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    
}

/// A type to manage user notifications.
///
/// For an instance of `UserNotificationManager` to work properly, it needs to know about all the features in the app that use user notifications.
/// So, typically an instance of `UserNotificationManager` is create at the core of the application and injected into components that need it.
public final class UserNotificationManager: UserNotificationManageable {
    
    /// User notification authorization status
    ///
    /// - notDetermined: Authorization status is not determined.
    /// - disabledByHost: The host (app) is not allowing user notifications.
    /// - deniedByUser: The user has denied authorization.
    /// - authorized: The host (app) and user have authorized user notifications.
    public enum AuthorizationStatus {
        case notDetermined
        case disabledByHost
        case deniedByUser
        case authorized
        
        init(_ status: UNAuthorizationStatus) {
            switch status {
            case .notDetermined, .provisional:
                self = .notDetermined
            case .denied:
                self = .deniedByUser
            case .authorized:
                self = .authorized
            }
        }
    }
    
    /// Response to an authorization request
    public struct AuthorizationResponse {
        
        /// How the authorization request was resolved
        ///
        /// - previouslyDetermined: The authorization was resolved based on existing information.
        /// - askedUser: The authorization was resolved by asking the user.
        public enum ResolutionMethod {
            case previouslyDetermined
            case askedUser
        }
        
        /// Returns whether user notifications are authorized.
        public var isAuthorised: Bool
        
        /// Returns how authorization decision was made.
        public var resolutionMethod: ResolutionMethod
    }
    
    var cachedAPNSToken: Data?
    
    private let authorizationManager: UserNotificationAuthorizationManaging
    private let host: UserNotificationHost
    private let notificationResolver: NotificationResolving
    public weak var delegate: UserNotificationManagerDelegate?
    
    public func designatedDelegate() -> UNUserNotificationCenterDelegate? {
        return notificationCenterDelegateContainer
    }
    
    init(host: UserNotificationHost, authorizationManager: UserNotificationAuthorizationManaging, notificationResolver: NotificationResolving) {
        self.host = host
        self.authorizationManager = authorizationManager
        self.notificationResolver = notificationResolver
        notificationCenterDelegateContainer.manager = self
    }
    
    public func requestAuthorization(completionHandler: @escaping (AuthorizationResponse) -> Void) {
        getAuthorizationStatus { status in
            switch status {
            case .notDetermined:
                self.authorizationManager.requestAuthorization { isAuthorized in
                    completionHandler(UserNotificationManager.AuthorizationResponse(isAuthorised: isAuthorized, resolutionMethod: .askedUser))
                }
            default:
                let isAuthorized = (status == .authorized)
                completionHandler(UserNotificationManager.AuthorizationResponse(isAuthorised: isAuthorized, resolutionMethod: .previouslyDetermined))
            }
        }
    }
    
    public func getAuthorizationStatus(completionHandler: @escaping (AuthorizationStatus) -> Void) {
        guard host.userNotificationsAreEnabled else {
            completionHandler(.disabledByHost)
            return
        }
        
        authorizationManager.getAuthorizationStatus { status in
            completionHandler(AuthorizationStatus(status))
        }
    }
    
    public func registerReceiver(_ receiver: NotificationReceivable) throws {
        let alreadyRegisterd = notificationResolver.receivers.contains { $0.identifier == receiver.identifier }
        guard alreadyRegisterd == false else { throw UserNotificationManagerError.receiverAlreadyRegister }
        notificationResolver.receivers.append(receiver)
    }
    
}

public extension UserNotificationManager {
    
    /// Creates a new user notifications manager.
    ///
    /// - Parameters:
    ///   - options: The user notification options requiring.
    ///   - host: The host context for user notifications.
    ///   - notificationResolver: The type that implements the mapping between a notification payload and a given receiver
    convenience init(requesting options: UNAuthorizationOptions, host: UserNotificationHost, notificationResolver: NotificationResolving) {
        let authorizationManager = UserNotificationAuthorizationManager(requesting: options)
        self.init(host: host, authorizationManager: authorizationManager, notificationResolver: notificationResolver)
    }
    
}

public extension UserNotificationManager {
    
    public func setAPNSToken(_ token: Data) {
        cachedAPNSToken = token
        notificationResolver.receivers.forEach { $0.didReceive(apnsToken: token) }
    }
    
    /// The method is to be called from the host app to let the registered receivers know that the User has successfully gained the minimum authorization level with the application
    public func didGainMinimumAuthenticationLevel() {
        notificationResolver.receivers.forEach { $0.associateToken() }
    }
    
    /// The method is to be called from the host app to let the registered receivers know that the User has removed the necessary minimum authorization level from the application
    public func didRemoveMinimumAuthenticationLevel() {
        notificationResolver.receivers.forEach { $0.disassociateToken() }
    }
    
    public func didReceiveNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let receiver = notificationResolver.receiver(for: userInfo),
              let payload = receiver.decode(userInfo) else {
                completionHandler(.noData)
                return
        }
        receiver.didReceiveNotification(payload, fetchCompletionHandler: completionHandler)
    }
    
}

extension UserNotificationManager {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        willPresentNotification(notification.request.content.userInfo, withCompletionHandler: completionHandler)
    }
    
    func willPresentNotification(_ userInfo: [AnyHashable: Any], withCompletionHandler completionHandler: ((UNNotificationPresentationOptions) -> Void)?) {
        guard let receiver = notificationResolver.receiver(for: userInfo),
              let payload = receiver.decode(userInfo) else {
                completionHandler?([])
                return
        }
        receiver.willPresentNotification(payload, presentationOptions: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let delegate = delegate else {
            completionHandler()
            return
        }
        delegate.userNotificationManager(self, didReceive: response, withCompletionHandler: completionHandler)
    }

}

//MARK: Firebase configuration

extension UserNotificationManager {
    // Private console simulation: 1:557180706253:ios:5aedc52956b22d68917884
    // Banxico console simulation: 1:352548351493:ios:6675d0b78e55fdd239b66c

    public func configureFirebase() {
        
        let googleID = "557180706253"
        let iOSID = "5aedc52956b22d68917884"
        let googleAppID = String(format: "1:%@:ios:%@", googleID, iOSID)
        let options = FirebaseOptions(googleAppID: googleAppID, gcmSenderID: googleID)
        
        if FirebaseApp.app() != nil {
            FirebaseApp.app()?.delete({ _ in
                FirebaseApp.configure(options: options)
            })
        } else {
            FirebaseApp.configure(options: options)
        }
    }
    
    public func configureFirebaseOptions(googleID: String, iOSID: String, completionHandler: @escaping (Bool) -> Void) {
        let googleAppID = String(format: "1:%@:ios:%@", googleID, iOSID)
        let options = FirebaseOptions(googleAppID: googleAppID, gcmSenderID: googleID)
        if FirebaseApp.app() != nil {
            FirebaseApp.app()?.delete({ _ in
                FirebaseApp.configure(options: options)
                completionHandler(true)
            })
        } else {
            FirebaseApp.configure(options: options)
            completionHandler(false)
        }
    }
    
    public func getFirebaseToken(completion: @escaping (String?) -> Void) {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                completion(nil)
            } else {
                completion(result?.token)
            }
        })
    }
    
}

private class NotificationCenterDelegateContainer: NSObject, UNUserNotificationCenterDelegate {
    
    weak var manager: UserNotificationManager?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        manager?.userNotificationCenter(center, willPresent: notification, withCompletionHandler: completionHandler)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        manager?.userNotificationCenter(center, didReceive: response, withCompletionHandler: completionHandler)
    }
    
}
