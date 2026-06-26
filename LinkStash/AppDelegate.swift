//
//  AppDelegate.swift
//  LinkStash
//
//  Created by Prisha Agarwalla on 6/20/26.
//
import AppKit
import SwiftUI
import CoreText

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    // Keep store + hostingController as strong properties so they are never deallocated
    var store = LinkStore()
    var hostingController: NSHostingController<AnyView>!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Register custom fonts programmatically (UIAppFonts is iOS-only, doesn't work on macOS)
        for name in ["Caveat-Bold", "PatrickHand-Regular", "Kalam-Regular"] {
            if let url = Bundle.main.url(forResource: name, withExtension: "ttf") {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
                print("✅ Registered font: \(name)")
            } else {
                print("❌ Font not found in bundle: \(name)")
            }
        }

        // Menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "link.circle.fill",
                                   accessibilityDescription: "LinkStash")
            button.action = #selector(togglePopover)
        }

        // Build the SwiftUI view — .preferredColorScheme(.light) forces light rendering
        // regardless of the user's system appearance, so custom hex colors always show correctly
        let rootView = AnyView(
            ContentView()
                .environmentObject(store)
                .preferredColorScheme(.light)
        )
        hostingController = NSHostingController(rootView: rootView)
        // Make the NSView layer-backed with the paper background so nothing bleeds through
        hostingController.view.wantsLayer = true
        hostingController.view.layer?.backgroundColor = NSColor(red: 251/255, green: 246/255, blue: 233/255, alpha: 1).cgColor

        // Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 540)
        popover.behavior = .transient
        popover.appearance = NSAppearance(named: .aqua)
        popover.contentViewController = hostingController
    }
    // this runs every time the menu bar icon is clicked
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }
        if popover.isShown {
            popover.performClose(nil)
        } else {
            // show the popover below the menu bar icon
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // bring app to front so you can type in the text field
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
