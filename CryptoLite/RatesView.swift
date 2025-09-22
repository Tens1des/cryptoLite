//
//  RatesView.swift
//  CryptoLite
//
//  Created by AI Assistant on 22.09.2025.
//

import SwiftUI

struct RatesView: View {
    @State private var coins: [CoinMarket] = []
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?
    @State private var timerId = UUID()
    @State private var query: String = ""
    @StateObject private var favorites = FavoritesStore()
    
    private let client: CoinGeckoClient = {
        let config = CoinGeckoClient.Configuration(
            apiBaseURL: URL(string: "https://api.coingecko.com/api/v3/")!,
            demoApiKey: Secrets.coinGeckoDemoApiKey
        )
        return CoinGeckoClient(config: config)
    }()
    private let pinnedIds = ["bitcoin", "ethereum", "tether"] // BTC, ETH, USDT
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading && coins.isEmpty {
                    ProgressView()
                } else if let errorMessage {
                    VStack(spacing: 12) {
                        Text(errorMessage).foregroundStyle(.secondary)
                        Button("Повторить") { Task { await load() } }
                    }
                } else {
                    VStack(spacing: 10) {
                        SearchField(text: $query)
                        HeaderRow()
                        List {
                            ForEach(filteredCoins) { coin in
                                RateCard(coin: coin, isFavorite: favorites.isFavorite(coin.id)) {
                                    favorites.toggle(coin.id)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }
                        .refreshable { await load() }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                    }
                    .padding(.horizontal, 12)
                }
            }
            // без заголовка и кнопок в навбаре
        }
        .task { await load() }
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }
    
    private var filteredCoins: [CoinMarket] {
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else { return coins }
        return coins.filter { $0.name.localizedCaseInsensitiveContains(text) || $0.symbol.localizedCaseInsensitiveContains(text) }
    }
    
    private func startTimer() {
        timerId = UUID()
        let currentId = timerId
        Task { @MainActor in
            while currentId == timerId {
                try? await Task.sleep(nanoseconds: 300 * 1_000_000_000) // 5 минут
                await load()
            }
        }
    }
    
    private func stopTimer() {
        timerId = UUID()
    }
    
    @MainActor
    private func load() async {
        isLoading = coins.isEmpty
        errorMessage = nil
        do {
            // Сначала закрепленные монеты, затем топ-10
            let pinned = try await client.fetchCoinMarkets(vsCurrency: "usd", ids: pinnedIds, perPage: pinnedIds.count)
            let top = try await client.fetchCoinMarkets(vsCurrency: "usd", ids: nil, perPage: 10)
            // Убираем дубликаты по id, сохраняя порядок
            var seen: Set<String> = []
            var result: [CoinMarket] = []
            for item in pinned + top {
                if seen.insert(item.id).inserted { result.append(item) }
            }
            coins = result
        } catch {
            errorMessage = (error as NSError).localizedDescription
        }
        isLoading = false
    }
}

private struct RateRow: View {
    let coin: CoinMarket
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.image ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name).font(.subheadline).fontWeight(.semibold)
                Text(coin.symbol.uppercased()).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatPrice(coin.currentPrice)).font(.subheadline)
                changeView
            }
        }
        .padding(.vertical, 6)
    }
    
    private var changeView: some View {
        let change = coin.priceChangePercentage24H ?? 0
        let isUp = change >= 0
        return HStack(spacing: 3) {
            Image(systemName: isUp ? "arrow.up" : "arrow.down")
            Text(String(format: "%@%.2f%%", isUp ? "+" : "", abs(change)))
        }
        .font(.caption2)
        .foregroundStyle(isUp ? Color.green : Color.red)
    }
    
    private func formatPrice(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = value < 1 ? 6 : 2
        return f.string(from: NSNumber(value: value)) ?? "$0"
    }
}

#Preview {
    RatesView()
}

// MARK: - UI Components

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

private struct HeaderRow: View {
    var body: some View {
        HStack {
            Label("Name", systemImage: "c.circle")
                .labelStyle(.titleAndIcon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("Current price").font(.caption).foregroundStyle(.secondary)
                Text("% 24h").font(.caption2).foregroundStyle(.secondary)
            }
            Image(systemName: "star")
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

private struct RateCard: View {
    let coin: CoinMarket
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: coin.image ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Circle().fill(Color.gray.opacity(0.2))
            }
            .frame(width: 28, height: 28)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.name).font(.subheadline).fontWeight(.semibold)
                Text(coin.symbol.uppercased()).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatPrice(coin.currentPrice)).font(.subheadline)
                changeView
            }
            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(isFavorite ? Color.blue : Color.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 6, y: 2)
        )
    }
    
    private var changeView: some View {
        let change = coin.priceChangePercentage24H ?? 0
        let isUp = change >= 0
        return HStack(spacing: 3) {
            Image(systemName: isUp ? "arrow.up" : "arrow.down")
            Text(String(format: "%@%.2f%%", isUp ? "+" : "", abs(change)))
        }
        .font(.caption2)
        .foregroundStyle(isUp ? Color.green : Color.red)
    }
    
    private func formatPrice(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = value < 1 ? 6 : 2
        return f.string(from: NSNumber(value: value)) ?? "$0"
    }
}


