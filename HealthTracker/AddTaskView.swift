import SwiftUI

struct AddTaskView: View {
import SwiftUI
import Firebase

struct AddTaskView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var taskName = ""
    @State private var scheduleTime: Double = 0
    var sleepEndDate: Date?
    var notificationManager: NotificationManager
    var taskStore: TaskStore

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Details")) {
                    TextField("Task Name", text: $taskName)
                }

                Section(header: Text("Scheduling")) {
                    VStack {
                        Text("Schedule \(Int(scheduleTime)) minutes after waking up")
                        Slider(value: $scheduleTime, in: 0...120, step: 5)
                    }
                }
            }
            .navigationTitle("Add Task")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                addTask()
            })
        }
    }

    private func addTask() {
        var newTask = Task(name: taskName)
        if let sleepEndDate = sleepEndDate {
            newTask.scheduledDate = sleepEndDate.addingTimeInterval(scheduleTime * 60)
        }
        if let userId = Auth.auth().currentUser?.uid {
            newTask.userId = userId
        }

        taskStore.addTask(newTask)
        notificationManager.scheduleNotification(for: newTask)
        presentationMode.wrappedValue.dismiss()
    }
}
