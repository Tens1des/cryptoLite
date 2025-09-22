import Foundation

struct GlossaryEntry: Identifiable, Codable, Equatable {
    let id: String
    let letter: String
    let term: String
    let definition: String
    let detail: String
}

final class GlossaryStore: ObservableObject {
    @Published private(set) var entries: [GlossaryEntry] = []
    @Published private(set) var favorites: Set<String> = []
    
    private let favKey = "glossary.favorites"
    
    init() {
        load()
        if let arr = UserDefaults.standard.array(forKey: favKey) as? [String] {
            favorites = Set(arr)
        }
    }
    
    private func load() {
        guard let url = Bundle.main.url(forResource: "glossary_terms", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([GlossaryEntry].self, from: data) else { return }
        entries = decoded
    }
    
    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }
    func toggleFavorite(_ id: String) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
        UserDefaults.standard.set(Array(favorites), forKey: favKey)
        objectWillChange.send()
    }
}


