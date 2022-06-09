import Foundation

enum Priority: Int {
    case high
    case medium
    case low
}

struct Task {
    let title: String
    let Priority: Priority
}
