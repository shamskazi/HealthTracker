import UserNotifications

class NotificationManager {
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            completion(success)
        }
    }

    func scheduleNotification(for task: Task) {
        guard let taskName = task.name, let scheduledDate = task.scheduledDate else { return }

        let content = UNMutableNotificationContent()
        content.title = "Health Tracker"
        content.subtitle = taskName
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        guard let taskId = task.id else { return }
        let request = UNNotificationRequest(identifier: taskId, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(for task: Task) {
        guard let taskId = task.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [taskId])
    }
}
