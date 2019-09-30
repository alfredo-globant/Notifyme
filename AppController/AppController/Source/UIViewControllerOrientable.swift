import UIKit

/// Marker protocol to let UIViewController express their orientation settings.
public protocol UIViewControllerOrientable {
    
    var supportedInterfaceOrientations: UIInterfaceOrientationMask { get }
    
}
