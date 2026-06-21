import SwiftUI

struct ContentView: View {

    // @EnvironmentObject = shared data passed down from AppDelegate

    // a global variable that the whole app can read/write

    @EnvironmentObject var store: LinkStore

    @State private var urlInput = ""         // what's typed in the text field

    @State private var selectedCategory = "General"

    let categories = ["General", "Jobs", "Articles", "Opportunities", "To Do", "Videos"]

    var body: some View {

        VStack(spacing: 0) {

            // header

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

            // Input Area

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

            // Links list

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

// Each row in the list

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

// Colored category tag

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




