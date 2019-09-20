import Foundation
import Notifications

final class MockNotificationResolver: NotificationResolving {
    var receivers: [NotificationReceivable] = []
    
    var stubbedReceiverForPayload: NotificationReceivable?
    
    func receiver(for payload: [AnyHashable : Any]) -> NotificationReceivable? {
        return stubbedReceiverForPayload
    }
}
