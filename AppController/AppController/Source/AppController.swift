import UIKit

public protocol AppController {
    var viewController: UIViewController { get }
    
    func open(_ url: URL) -> ConsumptionResult
    
    func didFinishLaunchingWithShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool
    
    func performActionFor(shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void)
    
    func didRegisterForRemoteNotifications(deviceToken: Data)
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

public extension AppController {
    
    func open(_ url: URL) -> ConsumptionResult {
        return .notConsumed
    }
    
    func didFinishLaunchingWithShortcutItem(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        return true
    }
    
    func performActionFor(shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Default completion to a successful execution
        completionHandler(true)
    }
    
    func didRegisterForRemoteNotifications(deviceToken: Data) {
        /* no-op */
    }
    
    func didReceiveRemoteNotification(userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Ensure that is if this method is not implemented by the conforming type
        // the completion handler is still called
        completionHandler(.noData)
    }
}

public enum ConsumptionResult {
    case consumed
    case notConsumed
}
