// AppEntry.swift
// DoceriWhiteboard
//
// App entry point. Configures the SwiftUI app lifecycle and
// injects the shared SessionStore into the environment.

import SwiftUI

@main
struct DoceriWhiteboardApp: App {

    @StateObject private var session = SessionStore()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(session)
                .onAppear {
                    AppOrientation.lock(to: .landscape)
                }
        }
    }
}

// MARK: - Orientation Helper
enum AppOrientation {
    static func lock(to orientation: UIInterfaceOrientationMask) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    }
}
