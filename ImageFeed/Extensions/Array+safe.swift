import UIKit

extension Array {
    func withReplaced(safe index: Int, newValue: Element) -> [Element] {
        guard indices.contains(index) else { return self }
        var newArray = self
        newArray[index] = newValue
        return newArray
    }
}
