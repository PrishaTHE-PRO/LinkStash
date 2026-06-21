# LinkStash — macOS Menu Bar App
### A beginner's guide to building your first Swift/Xcode project

---

## Your Idea, Refined

Your concept is solid and there's real demand for it — most people dump links into iMessages, Notes, or random browser tabs and never revisit them. Here's one important technical note:

**The Mac "notch" vs. the iPhone Dynamic Island are different things.** On iPhone, the Dynamic Island is a software UI element Apple built around the hardware cutout. On Mac, the notch is just a physical hole — apps can't officially "live" in it the same way.

**The best macOS equivalent** is a **menu bar app** — a small icon that sits in the top-right of your screen (like 1Password, Raycast, or Bartender). Click it → a panel drops down. This is actually *more* useful than a notch overlay because:
- It works on all Macs, not just notch models
- It's the standard Apple pattern — reviewers and users expect it
- It's approachable to build for a beginner
- Apps like Raycast, Paste, and CleanMyMac all use this pattern

You can still add a "drop near the notch" floating window as a later feature.

---

## Feature Ideas (Build Order)

**Core (Stage 1–2):**
- Paste a URL → save it instantly
- Choose a category: Jobs, Articles, Opportunities, To-Do, Videos, General
- Click any saved link to open it in your browser
- Swipe or click to delete a link
- Persists between app restarts (saved locally)

**Power Features (Stage 3–4):**
- Auto-detect link type (if URL contains "linkedin.com/jobs" → auto-tag as Jobs)
- Auto-fetch page title so you see "Google SWE Internship 2025" not a long URL
- Search bar to filter links
- Global keyboard shortcut (e.g., ⌘+Shift+L) to open from anywhere
- "Copy URL" button on each link
- Mark links as visited / unread badge count on menu bar icon

**Advanced (Stage 5+):**
- iCloud sync (see your links on iPhone too via SwiftData)
- Snooze a link (remind me in 3 days)
- Export to CSV / Notion
- Share sheet from Safari → send directly to LinkStash
- Notch overlay drop zone (floating window near notch)
- App Store submission

---

## Market Positioning

Apps like Raindrop.io, Pocket, and Instapaper exist but they're:
- Web-based, not native Mac
- Heavyweight (accounts, subscriptions)
- Not frictionless — you have to leave what you're doing

LinkStash's edge: **zero-friction, lives in your menu bar, no account needed, instant.** That's a real gap. For Apple internship portfolio purposes, a polished native macOS app with SwiftUI shows exactly what Apple wants to see.

---

## Development Stages

| Stage | What You Build | New Skills Learned |
|-------|---------------|-------------------|
| **1** | Menu bar app, paste & save links, list view, delete | Xcode setup, Swift basics, SwiftUI, UserDefaults |
| **2** | Categories, color badges, filter by category | Enums, computed properties, List filtering |
| **3** | Auto-fetch page titles from URLs | async/await, URLSession, networking |
| **4** | Global keyboard shortcut, clipboard detection | NSEvent, AppKit integration |
| **5** | Link previews (thumbnail + description) | Open Graph parsing, image loading |
| **6** | iCloud sync, App Store polish | SwiftData/CloudKit, entitlements |

---

## Swift vs Python — Quick Mental Map

Before the code, here's how Swift concepts map to things you know:

| Python | Swift |
|--------|-------|
| `class Foo:` | `class Foo {` |
| `def __init__(self)` | `init()` |
| `self.x = 5` | `var x = 5` (inside class) |
| `list = []` | `var list: [String] = []` |
| `dict = {}` | `var dict: [String: String] = [:]` |
| `print("hi")` | `print("hi")` ← same! |
| `if x == 5:` | `if x == 5 {` |
| `for item in items:` | `for item in items {` |
| `# comment` | `// comment` |
| decorators like `@property` | property wrappers like `@State`, `@Published` |
| type hints (optional) | types are **required** in Swift |

Swift is **strongly typed** — you must say whether something is a `String`, `Int`, `Bool`, etc. Think of it like Python with mandatory type hints everywhere.

---

## Stage 1 — Complete Code

### Xcode Project Setup (do this first)

1. Download **Xcode** from the Mac App Store (it's free, ~12GB)
2. Open Xcode → **Create New Project**
3. Choose **macOS** tab → **App** → click Next
4. Fill in:
   - Product Name: `LinkStash`
   - Team: (leave as None or add your Apple ID)
   - Organization Identifier: `com.yourname.linkstash`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - ✅ Uncheck "Include Tests" for now
5. Click Next → save somewhere on your Desktop

You'll see a project with some default files. We'll replace them.

### One Setting to Change First

In the left sidebar, click your project name (LinkStash) → click the **LinkStash target** → go to **Info** tab → find (or add) the key:

```
Application is agent (UIElement) = YES
```

This makes your app a menu bar app with no Dock icon. To add it manually: scroll to the bottom of Info.plist entries → click the + button → type `Application is agent` → set value to `YES`.

---

### File 1: `LinkStashApp.swift`

This is the entry point — like `if __name__ == "__main__":` in Python.

Replace the default contents with:

```swift
import SwiftUI

@main  // This tells Swift: "start the app here"
struct LinkStashApp: App {
    // This connects our AppDelegate (menu bar setup) to the app
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // We don't want a regular window, just the menu bar icon
        // Settings scene is required but we give it an empty view
        Settings {
            EmptyView()
        }
    }
}
```

---

### File 2: `AppDelegate.swift` (create this file)

Right-click the LinkStash folder in the sidebar → **New File** → **Swift File** → name it `AppDelegate.swift`

This is like the "setup" code that runs when the app launches. It creates the menu bar icon and the dropdown panel.

```swift
import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // statusItem = the icon in the top menu bar
    var statusItem: NSStatusItem!
    // popover = the dropdown panel that appears when you click the icon
    var popover: NSPopover!

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Create the menu bar icon
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            // SF Symbols name for a chain link icon — Apple's built-in icon library
            button.image = NSImage(systemSymbolName: "link.circle.fill",
                                   accessibilityDescription: "LinkStash")
            // When clicked, call our togglePopover function
            button.action = #selector(togglePopover)
        }

        // 2. Create the popover (the dropdown UI)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 500)
        // .transient = closes when you click anywhere else
        popover.behavior = .transient
        // Plug in our SwiftUI view as the contents
        popover.contentViewController = NSHostingController(
            rootView: ContentView().environmentObject(LinkStore())
        )
    }

    // This runs every time the menu bar icon is clicked
    @objc func togglePopover() {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            // Show the popover below the menu bar icon
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            // Bring app to front so you can type in the text field
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
```

---

### File 3: `LinkStore.swift` (create this file)

This is your **data model** — like a Python class that holds all your links and saves them to disk. `UserDefaults` is macOS's built-in simple key-value storage (like a persistent dictionary).

```swift
import Foundation

// A single saved link — like a Python dataclass
struct Link: Identifiable, Codable {
    // Identifiable: each link has a unique id (required for SwiftUI lists)
    // Codable: can be converted to/from JSON automatically

    let id: UUID          // Unique ID, auto-generated
    var url: String       // The URL string
    var title: String     // Display name
    var category: String  // e.g. "Jobs", "Articles"
    var dateAdded: Date   // When it was saved

    // Custom initializer (like __init__ in Python)
    init(url: String, title: String = "", category: String = "General") {
        self.id = UUID()
        self.url = url
        self.title = title.isEmpty ? url : title  // if no title, use the URL
        self.category = category
        self.dateAdded = Date()  // right now
    }
}

// ObservableObject = SwiftUI will automatically redraw the UI when this data changes
// Think of it like a reactive Python class
class LinkStore: ObservableObject {
    // @Published = "whenever this array changes, tell SwiftUI to update the screen"
    @Published var links: [Link] = []

    private let saveKey = "LinkStash_savedLinks"

    init() {
        load()  // Load saved links when app starts
    }

    // Add a new link to the top of the list
    func add(urlString: String, category: String) {
        // Clean up the URL — add https:// if missing
        var cleaned = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleaned.lowercased().hasPrefix("http") {
            cleaned = "https://\(cleaned)"
        }

        let newLink = Link(url: cleaned, category: category)
        links.insert(newLink, at: 0)  // insert at front so newest is at top
        save()
    }

    // Delete links (called by SwiftUI's swipe-to-delete)
    func delete(at offsets: IndexSet) {
        links.remove(atOffsets: offsets)
        save()
    }

    // Save to disk using UserDefaults (persistent storage)
    private func save() {
        if let encoded = try? JSONEncoder().encode(links) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    // Load from disk when app starts
    private func load() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Link].self, from: data) {
            links = decoded
        }
    }
}
```

---

### File 4: `ContentView.swift` (replace existing)

This is the **UI** — everything you see when you click the menu bar icon. SwiftUI is declarative, meaning you *describe* what the UI looks like, not how to draw it (similar to HTML/CSS vs. JavaScript).

```swift
import SwiftUI

struct ContentView: View {
    // @EnvironmentObject = shared data passed down from AppDelegate
    // Like a global variable that the whole app can read/write
    @EnvironmentObject var store: LinkStore

    @State private var urlInput = ""         // what's typed in the text field
    @State private var selectedCategory = "General"

    let categories = ["General", "Jobs", "Articles", "Opportunities", "To Do", "Videos"]

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ──────────────────────────────────────────
            HStack {
                Image(systemName: "link.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                Text("LinkStash")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                Text("\(store.links.count) saved")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            // ── Input Area ──────────────────────────────────────
            VStack(spacing: 10) {
                TextField("Paste a URL here...", text: $urlInput)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { saveLink() }  // press Enter to save

                HStack(spacing: 8) {
                    Picker("", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)

                    Button(action: saveLink) {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(urlInput.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(16)

            Divider()

            // ── Links List ──────────────────────────────────────
            if store.links.isEmpty {
                // Empty state
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text("No links yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Paste a URL above to get started")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                List {
                    ForEach(store.links) { link in
                        LinkRowView(link: link)
                    }
                    .onDelete(perform: store.delete)  // swipe to delete
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 360, height: 500)
    }

    func saveLink() {
        let trimmed = urlInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.add(urlString: trimmed, category: selectedCategory)
        urlInput = ""  // clear the text field after saving
    }
}

// ── Each row in the list ────────────────────────────────────────────

struct LinkRowView: View {
    let link: Link

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                CategoryBadge(category: link.category)
                Spacer()
                Text(link.dateAdded, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            // Clicking the URL opens it in the browser
            Button(action: openLink) {
                Text(link.url)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)
                    .truncationMode(.middle)  // shows beginning...end if too long
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    func openLink() {
        if let url = URL(string: link.url) {
            NSWorkspace.shared.open(url)  // opens in default browser
        }
    }
}

// ── Colored category tag ────────────────────────────────────────────

struct CategoryBadge: View {
    let category: String

    // Computed property — like a Python @property
    var color: Color {
        switch category {
        case "Jobs":          return .green
        case "Articles":      return .orange
        case "Opportunities": return .purple
        case "To Do":         return .red
        case "Videos":        return .pink
        default:              return .blue
        }
    }

    var body: some View {
        Text(category)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
```

---

## How to Run It

1. In Xcode, press **⌘+R** (or click the ▶ Play button)
2. The app will compile and launch — you'll see a chain link icon appear in your **top menu bar** (top right, near the clock)
3. Click it → your popup appears
4. Paste a URL → pick a category → hit Save or press Enter
5. Your link appears in the list — click it to open in browser, swipe left to delete

**If you don't see the menu bar icon:** Make sure you set `Application is agent = YES` in your Info.plist (the step above). Without that, the app tries to make a Dock window, which won't show.

---

## Common Beginner Errors

| Error | What it means | Fix |
|-------|--------------|-----|
| `Cannot find type 'LinkStore'` | File not in project | Make sure all .swift files are in the LinkStash target (check the Target Membership checkbox when you create a file) |
| `Value of type 'ContentView' has no member 'store'` | Missing @EnvironmentObject | Make sure AppDelegate passes `.environmentObject(LinkStore())` |
| Menu bar icon doesn't show | LSUIElement not set | Add `Application is agent = YES` to Info.plist |
| App opens a window instead | Same as above | Same fix |

---

## What to Build in Stage 2

Once Stage 1 works:
1. Add a **search bar** — filter `store.links` where `link.url` or `link.category` contains the search text
2. Add **filter buttons** at the top (All / Jobs / Articles / etc.)
3. Auto-detect categories from URL patterns:
   ```swift
   func guessCategory(from url: String) -> String {
       if url.contains("linkedin.com") || url.contains("jobs") { return "Jobs" }
       if url.contains("youtube.com") || url.contains("youtu.be") { return "Videos" }
       return "General"
   }
   ```

Good luck — this is a genuinely useful app and a strong portfolio piece for Apple. 🔗
