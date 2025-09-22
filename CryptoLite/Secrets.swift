import Foundation

enum Secrets {
    static let coinGeckoDemoApiKey: String? = {
        guard
            let url = Bundle.main.url(forResource: "Secret", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any]
        else { return nil }
        return dict["COINGECKO_DEMO_API_KEY"] as? String
    }()
}


