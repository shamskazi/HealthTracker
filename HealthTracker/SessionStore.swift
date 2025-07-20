import SwiftUI
import Firebase
import Combine

class SessionStore: ObservableObject {
    @Published var isLoggedIn = false
    var handle: AuthStateDidChangeListenerHandle?

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            if let _ = user {
                self.isLoggedIn = true
            } else {
                self.isLoggedIn = false
            }
        }
    }

    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
