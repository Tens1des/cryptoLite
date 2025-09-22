import Foundation

struct EducationArticle: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let summary: String
    let image: String
    let imageURL: String?
    let content: String
}

final class EducationStore: ObservableObject {
    @Published private(set) var articles: [EducationArticle] = []
    @Published private(set) var favorites: Set<String> = []
    
    private let favoritesKey = "education.favorites"
    
    init() {
        load()
        if let saved = UserDefaults.standard.array(forKey: favoritesKey) as? [String] {
            favorites = Set(saved)
        }
    }
    
    func toggleFavorite(_ id: String) {
        if favorites.contains(id) { favorites.remove(id) } else { favorites.insert(id) }
        UserDefaults.standard.set(Array(favorites), forKey: favoritesKey)
        objectWillChange.send()
    }
    
    func isFavorite(_ id: String) -> Bool { favorites.contains(id) }
    
    private func load() {
        guard let url = Bundle.main.url(forResource: "education_articles", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([EducationArticle].self, from: data) else { return }
        articles = decoded
    }
}


