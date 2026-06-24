//
//  AppDelegate.swift
//  LinkStash
//
//  Created by Prisha Agarwalla on 6/20/26.
//
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // statusItem = the icon in the top menu bar
    var statusItem: NSStatusItem!
    
    // popover = the dropdown panel that appears when you click the icon
    var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // create menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            // SF Symbols names for a chain link icon
            button.image = NSImage(systemSymbolName: "link.circle.fill",
                                   
                                   accessibilityDescription: "LinkStash")
            // when clicked, call out togglePopover function
            button.action = #selector(togglePopover)
        }
        // the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 540)
        // .trasient = closes when i clcik anywhere else
        popover.behavior = .transient
        // plug in out SwiftUI view as the contents
        popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(LinkStore())
        )
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
