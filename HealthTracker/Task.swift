import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Task: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var completed: Bool = false
    var scheduledDate: Date?
    var userId: String?
}
