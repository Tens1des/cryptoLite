import SwiftUI

struct EducationView: View {
    @StateObject private var store = EducationStore()
    @State private var query: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("The latest articles in the\nworld of crypto")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.blue)
                    .padding(.top, 8)
                SearchField(text: $query)
                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(filtered) { article in
                            NavigationLink {
                                EducationDetailView(article: article, isFavorite: store.isFavorite(article.id)) {
                                    store.toggleFavorite(article.id)
                                }
                            } label: {
                                EducationCard(article: article, isFavorite: store.isFavorite(article.id)) {
                                    store.toggleFavorite(article.id)
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
    
    private var filtered: [EducationArticle] {
        let t = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard t.isEmpty == false else { return store.articles }
        return store.articles.filter { $0.title.localizedCaseInsensitiveContains(t) || $0.summary.localizedCaseInsensitiveContains(t) }
    }
}

// Поисковое поле (локальная версия для экрана Education)
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

private struct EducationCard: View {
    let article: EducationArticle
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HStack(alignment: .top, spacing: 12) {
                ArticleImage(article: article)
                    .frame(width: 120, height: 120)
                    .cornerRadius(16)
                VStack(alignment: .leading, spacing: 6) {
                    Text(article.title).font(.headline)
                    Text(article.summary).font(.subheadline).foregroundStyle(.secondary)
                    Text("Read all").font(.caption).foregroundStyle(.blue)
                }
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18).fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, y: 2)
            )
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.8)))
            }
            .padding(8)
        }
    }
}

private struct EducationDetailView: View {
    let article: EducationArticle
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ArticleImage(article: article)
                    .frame(height: 200)
                    .cornerRadius(16)
                HStack {
                    Text(article.title).font(.title3.weight(.semibold))
                    Spacer()
                    Button(action: onToggleFavorite) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(isFavorite ? .blue : .secondary)
                    }
                }
                Text(article.content).font(.body)
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

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


