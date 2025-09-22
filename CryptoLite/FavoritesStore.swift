import Foundation

final class FavoritesStore: ObservableObject {
    @Published private(set) var favoriteIds: Set<String>
    private let defaultsKey = "favorites.coin.ids"
    
    init() {
        if let saved = UserDefaults.standard.array(forKey: defaultsKey) as? [String] {
            favoriteIds = Set(saved)
        } else {
            favoriteIds = []
        }
    }
    
    func isFavorite(_ id: String) -> Bool { favoriteIds.contains(id) }
    
    func toggle(_ id: String) {
        if favoriteIds.contains(id) {
            favoriteIds.remove(id)
        } else {
            favoriteIds.insert(id)
        }
        persist()
    }
    
    private func persist() {
        UserDefaults.standard.set(Array(favoriteIds), forKey: defaultsKey)
    }
}


