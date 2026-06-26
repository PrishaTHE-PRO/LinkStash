import SwiftUI

// MARK: - Main View
struct ContentView: View {
    @EnvironmentObject var store: LinkStore

    @State private var urlInput        = ""
    @State private var selectedCategory = "General"
    @State private var filterCategory  = "All"
    @State private var isSaving        = false
    @State private var savedFeedback   = false

    /// Categories shown in filter tabs (All + save categories)
    private let filterCats = ["All", "General", "Jobs", "Articles",
                               "Opportunities", "To Do", "Videos"]

    private var hasURL: Bool {
        !urlInput.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var filteredLinks: [Link] {
        store.links.filter {
            filterCategory == "All" || $0.category == filterCategory
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            PDRule(color: PD.Colors.paper400)
            inputArea
            PDRule(color: PD.Colors.paper300)
            filterTabs
            PDRule(color: PD.Colors.paper300)
            linksArea
        }
        .frame(width: 360, height: 540)
        .background(PD.Colors.paper100)
    }

    // ── HEADER ────────────────────────────────────────────────
    private var headerView: some View {
        HStack(spacing: 10) {
            Image(systemName: "link")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(PD.Colors.ink800)

            Text("LinkStash")
                .font(PD.script(22))
                .foregroundColor(PD.Colors.ink900)

            Spacer()

            // Washi-tape count badge
            Text("\(store.links.count) stashed")
                .font(PD.marker(11))
                .fontWeight(.semibold)
                .foregroundColor(PD.Colors.ink800)
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(PD.Colors.hiYellow)
                .overlay(
                    Rectangle()
                        .strokeBorder(PD.Colors.hiYellowDeep, lineWidth: 1.5)
                )
                .rotationEffect(.degrees(1.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PD.Colors.paper50)
    }

    // ── INPUT AREA ────────────────────────────────────────────
    private var inputArea: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Label
            Text("DROP A LINK")
                .font(PD.marker(10))
                .fontWeight(.semibold)
                .foregroundColor(PD.Colors.ink300)
                .tracking(1.8)
                .padding(.bottom, 7)

            // Underline-only text field
            VStack(spacing: 0) {
                TextField("https://…", text: $urlInput)
                    .textFieldStyle(.plain)
                    .font(PD.body(15))
                    .foregroundColor(PD.Colors.ink900)
                    .onChange(of: urlInput) { newVal in
                        selectedCategory = guessCategory(from: newVal)
                    }
                    .onSubmit { saveLink() }

                // Underline – blue when URL is present
                Rectangle()
                    .fill(hasURL ? PD.Colors.accent : PD.Colors.ink100)
                    .frame(height: 2)
                    .padding(.top, 6)
                    .animation(.easeInOut(duration: 0.2), value: hasURL)
            }

            // Detected category + Save button – slides in when URL is pasted
            if hasURL {
                HStack(spacing: 8) {
                    Text("detected →")
                        .font(PD.body(11))
                        .foregroundColor(PD.Colors.ink300)

                    CategoryBadge(category: selectedCategory)

                    Spacer()

                    saveButton
                }
                .padding(.top, 10)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(16)
        .background(PD.Colors.paper50)
        .animation(.easeOut(duration: 0.22), value: hasURL)
    }

    private var saveButton: some View {
        let label: String = {
            if isSaving      { return "saving…" }
            if savedFeedback { return "✓ stashed!" }
            return "stash it →"
        }()
        let bg = savedFeedback ? PD.Colors.accentSuccess : PD.Colors.accent

        return Button(action: saveLink) {
            Text(label)
                .font(PD.marker(13))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 5)
                .background(bg.animation(.easeInOut(duration: 0.3), value: savedFeedback))
                .cornerRadius(2)
                .overlay(
                    RoundedRectangle(cornerRadius: 2)
                        .strokeBorder(PD.Colors.accentInk, lineWidth: 2)
                )
                .shadow(color: PD.Colors.accentInk, radius: 0, x: 2, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(isSaving)
    }

    // ── FILTER TABS (highlighter-underline style) ─────────────
    private var filterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(filterCats, id: \.self) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            filterCategory = cat
                        }
                    } label: {
                        VStack(spacing: 0) {
                            Text(cat)
                                .font(PD.marker(13))
                                .fontWeight(filterCategory == cat ? .bold : .regular)
                                .foregroundColor(filterCategory == cat
                                    ? PD.Colors.ink900
                                    : PD.Colors.ink400)
                                .padding(.horizontal, 10)
                                .padding(.top, 8)
                                .padding(.bottom, 6)

                            // Highlighter underline on active tab
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(filterCategory == cat
                                    ? PD.Colors.hiYellow : Color.clear)
                                .frame(height: 3)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 6)
        }
        .frame(height: 38)
        .background(PD.Colors.paper100)
    }

    // ── LINKS LIST ────────────────────────────────────────────
    @ViewBuilder
    private var linksArea: some View {
        if filteredLinks.isEmpty {
            VStack(spacing: 8) {
                Text(hasURL ? "nothing here yet" : "nothing here yet")
                    .font(PD.script(30))
                    .foregroundColor(PD.Colors.ink100)
                Text("paste a link above to get started")
                    .font(PD.body(12))
                    .foregroundColor(PD.Colors.ink300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(PD.Colors.paper100)
        } else {
            List {
                ForEach(filteredLinks) { link in
                    LinkRow(link: link) {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            filterCategory = link.category
                        }
                    }
                    .listRowBackground(PD.Colors.paper100)
                    .listRowSeparatorTint(PD.Colors.paper300)
                    .listRowInsets(EdgeInsets())
                }
                .onDelete { offsets in
                    let ids = offsets.map { filteredLinks[$0].id }
                    store.links.removeAll { ids.contains($0.id) }
                    store.savePublic()
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // ── ACTIONS ──────────────────────────────────────────────
    private func saveLink() {
        let trimmed = urlInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !isSaving else { return }
        isSaving = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            store.add(urlString: trimmed, category: selectedCategory)
            isSaving       = false
            savedFeedback  = true
            urlInput       = ""
            selectedCategory = "General"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                savedFeedback = false
            }
        }
    }

    private func guessCategory(from url: String) -> String {
        let l = url.lowercased()
        if l.contains("linkedin") || l.contains("greenhouse") ||
           l.contains("lever")    || l.contains("job")        ||
           l.contains("career")   { return "Jobs" }
        if l.contains("youtube")  || l.contains("youtu.be") ||
           l.contains("vimeo")    || l.contains("twitch")    { return "Videos" }
        if l.contains("medium")   || l.contains("substack") ||
           l.contains("dev.to")   || l.contains("blog")      { return "Articles" }
        if l.contains("internship") || l.contains("fellowship") ||
           l.contains("mlh")        || l.contains("hackathon")  { return "Opportunities" }
        return "General"
    }
}

// MARK: - Link Row  (Field Notes style)
struct LinkRow: View {
    let link: Link
    var onCategoryTap: () -> Void = {}

    @State private var isHovered = false

    /// Strips scheme + www, returns bare hostname
    private var domain: String {
        let raw = link.url.hasPrefix("http") ? link.url : "https://\(link.url)"
        guard let host = URL(string: raw)?.host else {
            return link.url.components(separatedBy: "/").first ?? link.url
        }
        return host.replacingOccurrences(of: "www.", with: "")
    }

    /// Human-readable title: if title was set to the raw URL, derive from path instead
    private var displayTitle: String {
        guard link.title != link.url, !link.title.hasPrefix("http") else {
            let raw = link.url.hasPrefix("http") ? link.url : "https://\(link.url)"
            guard let comps = URLComponents(string: raw) else { return link.url }
            let path = (comps.path.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
            return path.isEmpty ? domain : path
        }
        return link.title
    }

    var body: some View {
        HStack(spacing: 10) {
            faviconCircle

            VStack(alignment: .leading, spacing: 2) {
                Text(domain)
                    .font(PD.marker(13))
                    .fontWeight(.semibold)
                    .foregroundColor(PD.Colors.ink800)
                    .lineLimit(1)

                Text(displayTitle)
                    .font(PD.body(11))
                    .foregroundColor(PD.Colors.ink400)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Button(action: onCategoryTap) {
                    CategoryBadge(category: link.category)
                }
                .buttonStyle(.plain)

                Text(link.dateAdded, format: .dateTime.month(.abbreviated).day())
                    .font(PD.body(10))
                    .foregroundColor(PD.Colors.ink300)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(isHovered ? PD.Colors.paper200 : Color.clear)
        .contentShape(Rectangle())
        .onHover  { isHovered = $0 }
        .onTapGesture {
            if let url = URL(string: link.url) { NSWorkspace.shared.open(url) }
        }
    }

    private var faviconCircle: some View {
        let initial = domain.first.map { String($0).uppercased() } ?? "?"
        return ZStack {
            Circle().fill(PD.catBackground(for: link.category))
            Circle().strokeBorder(PD.catColor(for: link.category), lineWidth: 1.5)
            Text(initial)
                .font(PD.marker(14))
                .fontWeight(.bold)
                .foregroundColor(PD.catColor(for: link.category))
        }
        .frame(width: 32, height: 32)
    }
}

// MARK: - Category Badge
struct CategoryBadge: View {
    let category: String

    var body: some View {
        Text(category)
            .font(PD.marker(10))
            .fontWeight(.semibold)
            .foregroundColor(PD.catColor(for: category))
            .padding(.horizontal, 7)
            .padding(.vertical, 2)
            .background(PD.catBackground(for: category))
            .cornerRadius(2)
            .overlay(
                RoundedRectangle(cornerRadius: 2)
                    .strokeBorder(PD.catColor(for: category), lineWidth: 1)
            )
    }
}
