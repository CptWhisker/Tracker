import UIKit

extension UITableViewCell {
    func setLeftAndRightSeparatorInsets(to value: CGFloat) {
        separatorInset = UIEdgeInsets(top: 0, left: value, bottom: 0, right: value)
    }
    
    func removeSeparator() {
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
    }
}
