//
//  LinkStore.swift
//  LinkStash
//
//  Created by Prisha Agarwalla on 6/20/26.
//
import Foundation
import Combine
import SwiftUI

// a single saved link, like a python dataclass

struct Link: Identifiable, Codable {
    // Identifiable: each link has a unique id
    // codable: can be converted to/from JSON automatically
    
    let id: UUID  // unique ID that's auto-generated
    var url: String // the URL string
    var title: String // display name
    var category: String // e.g. "Jobs", "Articles"
    var dateAdded: Date // when it was saved
    // custom initializer
    init(url: String, title: String = "", category: String = "General") {
        self.id = UUID()
        self.url = url
        self.title = title.isEmpty ? url : title // if no title, use the URL
        self.category = category
        self.dateAdded = Date()
    }
}

class LinkStore: ObservableObject {
    @Published var links: [Link] = []
    private let saveKey = "LinkStash_savedLinks"
    init() {
        load() // load saved links when app starts
    }
    // add a new link to the top of the list
    func add(urlString: String, category: String) {
        // clean up the URL, add https:// if missing
        var cleaned = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !cleaned.lowercased().hasPrefix("http") {
            cleaned = "https://\(cleaned)"
        }
        let newLink = Link(url: cleaned, category: category)
        links.insert(newLink, at: 0) // insert at front so newest is at top
        save()
    }
    // delete links
    func delete(at offsets: IndexSet) {
        links.remove(atOffsets: offsets)
        save()
    }
    // public version used when ContentView modifies links directly (e.g. filtered delete)
    func savePublic() { save() }

    // save to disk using UserDefaults
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
