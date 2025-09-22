//
//  CoinGeckoClient.swift
//  CryptoLite
//
//  Created by AI Assistant on 22.09.2025.
//

import Foundation

/// Небольшой HTTP-клиент для CoinGecko Demo API
final class CoinGeckoClient {
    struct Configuration {
        let apiBaseURL: URL
        let demoApiKey: String?
        static let `default` = Configuration(
            apiBaseURL: URL(string: "https://api.coingecko.com/api/v3/")!,
            demoApiKey: nil
        )
    }
    
    enum ClientError: Error {
        case invalidResponse
        case httpStatus(Int)
    }
    
    private let config: Configuration
    private let urlSession: URLSession
    
    init(config: Configuration = .default, urlSession: URLSession = .shared) {
        self.config = config
        self.urlSession = urlSession
    }
    
    /// Маркеты монет с ценой и 24h изменением
    /// - Parameters:
    ///   - vsCurrency: например "usd"
    ///   - ids: конкретные ID (coingecko ids) через запятую. Если nil — вернет по order/market_cap_desc
    ///   - perPage: ограничение результата, по умолчанию топ-10
    func fetchCoinMarkets(
        vsCurrency: String = "usd",
        ids: [String]? = nil,
        perPage: Int = 10,
        page: Int = 1,
        order: String = "market_cap_desc"
    ) async throws -> [CoinMarket] {
        var components = URLComponents(url: config.apiBaseURL.appendingPathComponent("coins/markets"), resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "vs_currency", value: vsCurrency),
            URLQueryItem(name: "order", value: order),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "sparkline", value: "false"),
            URLQueryItem(name: "price_change_percentage", value: "24h")
        ]
        if let ids, ids.isEmpty == false {
            queryItems.append(URLQueryItem(name: "ids", value: ids.joined(separator: ",")))
        }
        if let key = config.demoApiKey, key.isEmpty == false {
            queryItems.append(URLQueryItem(name: "x_cg_demo_api_key", value: key))
        }
        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        if let key = config.demoApiKey, key.isEmpty == false {
            request.setValue(key, forHTTPHeaderField: "x-cg-demo-api-key")
        }
        
        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw ClientError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw ClientError.httpStatus(http.statusCode) }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode([CoinMarket].self, from: data)
    }
}

// MARK: - DTO

struct CoinMarket: Decodable, Identifiable {
    let id: String
    let symbol: String
    let name: String
    let image: String?
    let currentPrice: Double
    let priceChangePercentage24H: Double?
}


