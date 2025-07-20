import SwiftUI

struct AddTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var taskName = ""
    @State private var scheduleTime: Double = 0
    var sleepEndDate: Date?
    var notificationManager: NotificationManager

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
        withAnimation {
            let newTask = Task(context: viewContext)
            newTask.name = taskName
            newTask.completed = false

            if let sleepEndDate = sleepEndDate {
                newTask.scheduledDate = sleepEndDate.addingTimeInterval(scheduleTime * 60)
            }

            do {
                try viewContext.save()
                notificationManager.scheduleNotification(for: newTask)
                presentationMode.wrappedValue.dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
