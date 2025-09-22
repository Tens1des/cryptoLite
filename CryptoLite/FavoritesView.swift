import SwiftUI

struct FavoritesView: View {
    @StateObject private var favorites = FavoritesStore()
    @StateObject private var eduStore = EducationStore()
    @StateObject private var glossaryStore = GlossaryStore()
    @StateObject private var featuredStore = FeaturedArticlesStore.shared
    @State private var coins: [CoinMarket] = []
    @State private var isLoading: Bool = false
    private let client = CoinGeckoClient()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    coinsSection
                    featuredArticlesSection
                    educationSection
                    termsSection
                }
                .padding(16)
            }
            .task { await loadCoins() }
            .refreshable { await loadCoins() }
        }
    }
    
    private var coinsSection: some View {
        DisclosureGroup(isExpanded: .constant(true)) {
            VStack(spacing: 8) {
                ForEach(coins) { c in
                    FavoriteCoinCard(coin: c, isFavorite: favorites.isFavorite(c.id)) {
                        favorites.toggle(c.id)
                        Task { await loadCoins() }
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            HStack {
                Text("Favorite Coins").font(.title3.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.down")
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
    
    private var featuredArticlesSection: some View {
        DisclosureGroup(isExpanded: .constant(true)) {
            VStack(spacing: 8) {
                let fav = featuredStore.favorites
                if fav.isEmpty {
                    Text("Нет избранных статей. Отметь ⭐ в разделе Articles.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }
                ForEach(fav) { item in
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title).font(.subheadline).fontWeight(.semibold)
                            Text(item.subtitle).font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(action: { featuredStore.toggleFavorite(id: item.id, title: item.title, subtitle: item.subtitle) }) {
                            Image(systemName: "star.fill")
                        }
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.05), radius: 6, y: 2))
                }
            }
            .padding(.top, 8)
        } label: {
            HStack {
                Text("Featured articles").font(.title3.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.down")
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    private var educationSection: some View {
        DisclosureGroup(isExpanded: .constant(true)) {
            VStack(spacing: 8) {
                let favArticles = eduStore.articles.filter { eduStore.isFavorite($0.id) }
                if favArticles.isEmpty {
                    Text("No featured materials. Mark ⭐ in the Education section.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                }
                ForEach(favArticles) { a in
                    FavoriteArticleCard(article: a, isFavorite: eduStore.isFavorite(a.id)) {
                        eduStore.toggleFavorite(a.id)
                    }
                }
            }
            .padding(.top, 8)
        } label: { HStack { Text("Education").font(.title3.weight(.semibold)); Spacer(); Image(systemName: "chevron.down") } }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
    
    private var termsSection: some View {
        DisclosureGroup(isExpanded: .constant(true)) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(glossaryStore.entries.filter { glossaryStore.isFavorite($0.id) }) { e in
                    FavoriteTermCard(entry: e, isFavorite: glossaryStore.isFavorite(e.id)) {
                        glossaryStore.toggleFavorite(e.id)
                    }
                }
            }
            .padding(.top, 8)
        } label: {
            HStack {
                Text("Favorite terms").font(.title3.weight(.semibold))
                Spacer()
                Image(systemName: "chevron.down")
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground)))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }
    
    private func loadCoins() async {
        let ids = Array(favorites.favoriteIds)
        guard ids.isEmpty == false else { coins = []; return }
        isLoading = true
        do {
            let data = try await client.fetchCoinMarkets(vsCurrency: "usd", ids: ids, perPage: ids.count)
            await MainActor.run { coins = data }
        } catch {
            // ignore
        }
        isLoading = false
    }
}

private struct FavoriteCoinCard: View {
    let coin: CoinMarket
    let isFavorite: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.image ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: { Circle().fill(Color.gray.opacity(0.2)) }
            .frame(width: 28, height: 28)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name).font(.subheadline).fontWeight(.semibold)
                Text(coin.symbol.uppercased()).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatPrice(coin.currentPrice)).font(.subheadline)
                let change = coin.priceChangePercentage24H ?? 0
                HStack(spacing: 3) {
                    Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                    Text(String(format: "%@%.2f%%", change >= 0 ? "+" : "", abs(change)))
                }
                .font(.caption2)
                .foregroundStyle(change >= 0 ? Color.green : Color.red)
            }
            Button(action: onToggle) {
                Image(systemName: isFavorite ? "star.fill" : "star")
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
        )
    }
    private func formatPrice(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = value < 1 ? 6 : 2
        return f.string(from: NSNumber(value: value)) ?? "$0"
    }
}

private struct FavoriteArticleCard: View {
    let article: EducationArticle
    let isFavorite: Bool
    let onToggle: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ArticleImage(article: article)
                .frame(width: 96, height: 72)
                .cornerRadius(12)
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title).font(.subheadline).fontWeight(.semibold)
                Text(article.summary).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onToggle) { Image(systemName: isFavorite ? "star.fill" : "star") }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.05), radius: 6, y: 2))
    }
}

private struct FavoriteTermCard: View {
    let entry: GlossaryEntry
    let isFavorite: Bool
    let onToggle: () -> Void
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.term).font(.subheadline).fontWeight(.semibold)
                Text(entry.definition).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Button(action: onToggle) { Image(systemName: isFavorite ? "star.fill" : "star") }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 14).fill(Color(.systemBackground)).shadow(color: .black.opacity(0.05), radius: 6, y: 2))
    }
}

// Локальная версия ArticleImage (как в EducationView)
private struct ArticleImage: View {
    let article: EducationArticle
    var body: some View {
        Group {
            if let urlString = article.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    case .failure(_): Image(article.image).resizable().scaledToFill()
                    case .empty: ProgressView()
                    @unknown default: Image(article.image).resizable().scaledToFill()
                    }
                }
            } else {
                Image(article.image).resizable().scaledToFill()
            }
        }
        .clipped()
    }
}


