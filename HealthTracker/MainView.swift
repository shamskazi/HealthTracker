import SwiftUI
import Firebase

struct MainView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var taskStore = TaskStore()
    @State private var showingAddTaskView = false
    let healthKitManager = HealthKitManager()
    let notificationManager = NotificationManager()
    @State private var sleepStartDate: Date?
    @State private var sleepEndDate: Date?

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sleep Data")) {
                    if let startDate = sleepStartDate, let endDate = sleepEndDate {
                        Text("Slept from \(startDate, formatter: itemFormatter) to \(endDate, formatter: itemFormatter)")
                    } else {
                        Text("No sleep data found.")
                    }
                }
                ForEach(taskStore.tasks) { task in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(task.name)
                            Spacer()
                            if task.completed {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        if let scheduledDate = task.scheduledDate {
                            Text("Scheduled for: \(scheduledDate, formatter: itemFormatter)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        var updatedTask = task
                        updatedTask.completed.toggle()
                        taskStore.updateTask(updatedTask)
                    }
                }
                .onDelete(perform: deleteTask)
            }
            .navigationTitle("Health Tracker")
            .navigationBarItems(trailing: Button(action: {
                showingAddTaskView.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(sleepEndDate: sleepEndDate, notificationManager: notificationManager, taskStore: taskStore)
            }
            .onAppear(perform: setup)
        }
    }

    private func setup() {
        if let userId = Auth.auth().currentUser?.uid {
            taskStore.fetchTasks(userId: userId)
        }
        healthKitManager.requestAuthorization { success in
            if success {
                healthKitManager.fetchSleepData { startDate, endDate in
                    self.sleepStartDate = startDate
                    self.sleepEndDate = endDate
                }
            }
        }
        notificationManager.requestAuthorization { success in
            if !success {
                print("Notification authorization denied.")
            }
        }
    }

    private func deleteTask(offsets: IndexSet) {
        let tasksToDelete = offsets.map { taskStore.tasks[$0] }
        tasksToDelete.forEach { task in
            taskStore.deleteTask(task)
            notificationManager.cancelNotification(for: task)
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SessionStore())
    }
}
