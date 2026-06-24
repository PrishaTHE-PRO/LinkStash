import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: LinkStore

    @State private var urlInput = ""
    @State private var selectedCategory = "General"

    // STAGE 2: search text and active category filter
    @State private var searchText = ""
    @State private var filterCategory = "All"

    let categories = ["General", "Jobs", "Articles", "Opportunities", "To Do", "Videos"]

    // STAGE 2: filtered list based on search + category pill
    // This is a computed property — like a Python @property
    // It recalculates automatically whenever searchText, filterCategory, or store.links changes
    var filteredLinks: [Link] {
        store.links.filter { link in
            let matchesCategory = filterCategory == "All" || link.category == filterCategory
            let matchesSearch = searchText.isEmpty || link.url.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

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
                    .onSubmit { saveLink() }
                    // STAGE 2: auto-detect category as user types/pastes
                    .onChange(of: urlInput) { newValue in
                        let guessed = guessCategory(from: newValue)
                        selectedCategory = guessed
                    }

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

            // STAGE 2: Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search links...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))

            // Category filter pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterPill(label: "All", isSelected: filterCategory == "All") {
                        filterCategory = "All"
                    }
                    ForEach(categories, id: \.self) { cat in
                        FilterPill(label: cat, isSelected: filterCategory == cat) {
                            filterCategory = cat
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .frame(height: 40)

            Divider()

            // ── Links List ──────────────────────────────────────
            if filteredLinks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: searchText.isEmpty ? "tray" : "magnifyingglass")
                        .font(.system(size: 36))
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "No links yet" : "No results")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(searchText.isEmpty ? "Paste a URL above to get started" : "Try a different search or category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                List {
                    ForEach(filteredLinks) { link in
                        LinkRowView(link: link, onCategoryTap: { filterCategory = link.category })
                    }
                    .onDelete { offsets in
                        // Map filtered indices back to the real store indices before deleting
                        let idsToDelete = offsets.map { filteredLinks[$0].id }
                        store.links.removeAll { idsToDelete.contains($0.id) }
                        store.savePublic()
                    }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 360, height: 540) // slightly taller to fit search bar
    }

    func saveLink() {
        let trimmed = urlInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.add(urlString: trimmed, category: selectedCategory)
        urlInput = ""
        selectedCategory = "General"
    }

    // STAGE 2: auto-detect category from URL patterns
    func guessCategory(from url: String) -> String {
        let lower = url.lowercased()

        if lower.contains("linkedin.com") ||
           lower.contains("greenhouse.io") ||
           lower.contains("lever.co") ||
           lower.contains("workday.com") ||
           lower.contains("careers") ||
           lower.contains("job") {
            return "Jobs"
        }
        if lower.contains("youtube.com") ||
           lower.contains("youtu.be") ||
           lower.contains("vimeo.com") ||
           lower.contains("twitch.tv") {
            return "Videos"
        }
        if lower.contains("medium.com") ||
           lower.contains("substack.com") ||
           lower.contains("dev.to") ||
           lower.contains("blog") ||
           lower.contains("article") {
            return "Articles"
        }
        if lower.contains("internship") ||
           lower.contains("fellowship") ||
           lower.contains("hackathon") ||
           lower.contains("mlh.io") ||
           lower.contains("opportunity") {
            return "Opportunities"
        }
        return "General"
    }
}

// STAGE 2: filter pill button component
struct FilterPill: View {
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? Color.blue : Color(NSColor.controlBackgroundColor))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Color.blue.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// ── Each row in the list ────────────────────────────────────────────

struct LinkRowView: View {
    let link: Link
    var onCategoryTap: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Button(action: onCategoryTap) {
                    CategoryBadge(category: link.category)
                }
                .buttonStyle(.plain)
                Spacer()
                Text(link.dateAdded, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Button(action: openLink) {
                Text(link.url)
                    .font(.caption)
                    .foregroundColor(.blue)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }

    func openLink() {
        if let url = URL(string: link.url) {
            NSWorkspace.shared.open(url)
        }
    }
}

// ── Colored category tag ────────────────────────────────────────────

struct CategoryBadge: View {
    let category: String

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
