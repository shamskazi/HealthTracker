import SwiftUI
import Firebase

@main
struct HealthTrackerApp: App {
    init() {
        FirebaseApp.configure()
    }

    @StateObject var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(session)
        }
    }
}
