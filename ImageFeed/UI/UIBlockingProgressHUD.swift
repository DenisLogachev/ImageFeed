import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    private static var isVisible = false
    
    static func show() {
        guard !isVisible else { return }
        isVisible = true
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        isVisible = false
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
    
    static var isShowing: Bool {
        return isVisible
    }
}

