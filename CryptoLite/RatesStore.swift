import Foundation

/// Хранит последние курсы, чтобы калькулятор работал оффлайн
final class RatesStore: ObservableObject {
    static let shared = RatesStore()
    
    /// ключ: "BTC-USD" и т.п.
    @Published private(set) var priceByPair: [String: Double] = [:]
    private let defaultsKey = "rates.cache.v1"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: defaultsKey),
           let dict = try? JSONDecoder().decode([String: Double].self, from: data) {
            priceByPair = dict
        }
    }
    
    func updatePrice(crypto: String, fiat: String, price: Double) {
        let key = pairKey(crypto: crypto, fiat: fiat)
        priceByPair[key] = price
        persist()
    }
    
    func price(crypto: String, fiat: String) -> Double? {
        priceByPair[pairKey(crypto: crypto, fiat: fiat)]
    }
    
    private func persist() {
        if let data = try? JSONEncoder().encode(priceByPair) {
            UserDefaults.standard.set(data, forKey: defaultsKey)
        }
    }
    
    private func pairKey(crypto: String, fiat: String) -> String {
        crypto.uppercased() + "-" + fiat.uppercased()
    }
}


