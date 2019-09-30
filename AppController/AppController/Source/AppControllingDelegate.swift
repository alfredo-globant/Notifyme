import UIKit

open class AppControllingDelegate: NSObject, UIApplicationDelegate {
    public var window: UIWindow?
    
    private var appController: AppController!
    
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let window = self.makeWindow()
        self.window = window
        window.makeKeyAndVisible()
        
        do {
            let appController = try makeAppController()
            self.appController = appController
            window.rootViewController = appController.viewController
        }
        catch {
            fatalError("Failed to load root app controller: \(error)")
        }
        
        application.registerForRemoteNotifications()
        
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
            return appController.didFinishLaunchingWithShortcutItem(shortcutItem)
        }
        
        return true
    }
    
    open func makeAppController() throws -> AppController {
        fatalError("\(#function) should be overriden in a subclass")
    }
    
    public func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        switch (userActivity.activityType, userActivity.webpageURL) {
        case (NSUserActivityTypeBrowsingWeb, let url?):
            return open(url)
        default:
            return false
        }
    }
    
    public func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return open(url)
    }
    
    private func open(_ url: URL) -> Bool {
        return appController.open(url) == .consumed
    }
    
    func makeWindow() -> UIWindow {
        let screenBounds = UIScreen.main.bounds
        return UIWindow(frame: screenBounds)
    }
    
    public func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        appController.performActionFor(shortcutItem: shortcutItem, completionHandler: completionHandler)
    }
    
    //MARK: PushNotificationsHandling
    
    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        appController.didRegisterForRemoteNotifications(deviceToken: deviceToken)
    }
    
    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        appController.didReceiveRemoteNotification(userInfo: userInfo, fetchCompletionHandler: completionHandler)
    }
    
    //MARK: supportedInterfaceOrientations
    
    public func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return viewControllerOrientableSupportedInterfaceOrientations(for: window) ?? application.supportedInterfaceOrientations(for: window)
    }
    
    private func viewControllerOrientableSupportedInterfaceOrientations(for window: UIWindow?) -> UIInterfaceOrientationMask? {
        if let rootViewController = window?.rootViewController?.presentedViewController as? UIViewControllerOrientable {
            return rootViewController.supportedInterfaceOrientations
        }
        return nil
    }
    
}
