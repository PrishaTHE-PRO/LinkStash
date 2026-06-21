import SwiftUI

@main

struct LinkStashApp: App{
    // This conencts our AppDelegate (menu bar setup) to the app
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
