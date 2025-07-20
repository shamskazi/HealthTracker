import SwiftUI
import Firebase
import FirebaseFirestoreSwift

class TaskStore: ObservableObject {
    @Published var tasks = [Task]()
    private var db = Firestore.firestore()

    func fetchTasks(userId: String) {
        db.collection("tasks").whereField("userId", isEqualTo: userId).addSnapshotListener { querySnapshot, error in
            if let error = error {
                print("Error getting tasks: \(error.localizedDescription)")
                return
            }

            self.tasks = querySnapshot?.documents.compactMap { document in
                try? document.data(as: Task.self)
            } ?? []
        }
    }

    func addTask(_ task: Task) {
        do {
            _ = try db.collection("tasks").addDocument(from: task)
        } catch {
            print("Error adding task: \(error.localizedDescription)")
        }
    }

    func updateTask(_ task: Task) {
        if let taskId = task.id {
            do {
                try db.collection("tasks").document(taskId).setData(from: task)
            } catch {
                print("Error updating task: \(error.localizedDescription)")
            }
        }
    }

    func deleteTask(_ task: Task) {
        if let taskId = task.id {
            db.collection("tasks").document(taskId).delete()
        }
    }
}
