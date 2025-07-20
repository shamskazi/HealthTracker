import Foundation

struct Task: Identifiable {
    let id = UUID()
    var name: String
    var completed: Bool = false
}
