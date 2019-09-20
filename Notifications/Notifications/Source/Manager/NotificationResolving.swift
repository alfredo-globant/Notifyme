import Foundation

/// Interface for implementing the mapping between a notification payload and a given receiver
public protocol NotificationResolving: class {
    
    /// The array of registered receivers
    var receivers: [NotificationReceivable] { get set }
    
    /// Returns the receiver for a given payload if it exists
    func receiver(for payload: [AnyHashable : Any]) -> NotificationReceivable?
}
