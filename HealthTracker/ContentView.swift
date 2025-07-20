import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.name, ascending: true)],
        animation: .default)
    private var tasks: FetchedResults<Task>

    let healthKitManager = HealthKitManager()
    let notificationManager = NotificationManager()
    @State private var sleepStartDate: Date?
    @State private var sleepEndDate: Date?
    @State private var showingAddTaskView = false

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
                ForEach(tasks) { task in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(task.name ?? "Untitled")
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
                        toggleCompleted(task: task)
                    }
                }
                .onDelete(perform: deleteTasks)
            }
            .navigationTitle("Health Tracker")
            .navigationBarItems(trailing: Button(action: {
                showingAddTaskView.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddTaskView) {
                AddTaskView(sleepEndDate: sleepEndDate, notificationManager: notificationManager)
            }
            .onAppear(perform: setupHealthKit)
        }
    }

    private func setupHealthKit() {
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

    private func toggleCompleted(task: Task) {
        withAnimation {
            task.completed.toggle()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
