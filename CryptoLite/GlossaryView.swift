import SwiftUI

struct GlossaryView: View {
    @StateObject private var store = GlossaryStore()
    @State private var query: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                SearchField(text: $query)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12, pinnedViews: [.sectionHeaders]) {
                        ForEach(sectioned.keys.sorted(), id: \.self) { letter in
                            Section(header: letterHeader(letter)) {
                                ForEach(sectioned[letter] ?? []) { entry in
                                    NavigationLink {
                                        GlossaryDetailView(entry: entry, isFavorite: store.isFavorite(entry.id)) {
                                            store.toggleFavorite(entry.id)
                                        }
                                    } label: {
                                        GlossaryCard(entry: entry, isFavorite: store.isFavorite(entry.id)) {
                                            store.toggleFavorite(entry.id)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private func letterHeader(_ letter: String) -> some View {
        Text(letter)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .background(Color.clear)
    }
    
    private var filtered: [GlossaryEntry] {
        let t = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.isEmpty == false else { return store.entries }
        return store.entries.filter { $0.term.localizedCaseInsensitiveContains(t) || $0.definition.localizedCaseInsensitiveContains(t) || $0.letter.localizedCaseInsensitiveContains(t) }
    }
    
    private var sectioned: [String: [GlossaryEntry]] {
        Dictionary(grouping: filtered) { $0.letter }
    }
}

// Локальное поисковое поле для экрана глоссария
private struct SearchField: View {
    @Binding var text: String
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
            TextField("Search for cryptocurrency...", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct GlossaryCard: View {
    let entry: GlossaryEntry
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.term).font(.headline)
                Text(entry.definition).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
        )
    }
}

private struct GlossaryDetailView: View {
    let entry: GlossaryEntry
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text(entry.term).font(.title3.weight(.semibold))
                    Spacer()
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(isFavorite ? .blue : .secondary)
                    }
                }
                Text(entry.detail).font(.body)
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


