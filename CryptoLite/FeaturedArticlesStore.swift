import Foundation

struct FeaturedArticleItem: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let subtitle: String
}

final class FeaturedArticlesStore: ObservableObject {
    static let shared = FeaturedArticlesStore()
    @Published private(set) var favorites: [FeaturedArticleItem] = []
    private let key = "featured.articles.favorites"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FeaturedArticleItem].self, from: data) {
            favorites = decoded
        }
    }
    
    func isFavorite(_ id: String) -> Bool { favorites.contains { $0.id == id } }
    
    func toggleFavorite(id: String, title: String, subtitle: String) {
        if let idx = favorites.firstIndex(where: { $0.id == id }) {
            favorites.remove(at: idx)
        } else {
            favorites.insert(FeaturedArticleItem(id: id, title: title, subtitle: subtitle), at: 0)
        }
        persist()
        objectWillChange.send()
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

extension String {
    var slugifiedId: String {
        self.lowercased().replacingOccurrences(of: "[^a-z0-9]+", with: "-", options: .regularExpression).trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}


