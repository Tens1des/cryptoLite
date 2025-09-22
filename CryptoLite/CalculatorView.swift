import SwiftUI
import UIKit

private enum Crypto: String, CaseIterable { case BTC, ETH, USDT }
private enum Fiat: String, CaseIterable { case USD, EUR, RUB }

struct CalculatorView: View {
    @State private var topSafeAreaInset: CGFloat = 0
    @State private var fromAmount: String = ""
    @State private var toAmount: String = ""
    @State private var fromCrypto: Crypto = .BTC
    @State private var toFiat: Fiat = .USD
    @State private var errorMessage: String?
    @StateObject private var ratesStore = RatesStore.shared
    @State private var history: [Conversion] = ConversionStorage.load()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Cryptocurrency converter\nand calculator")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.blue)
                    .padding(.top, 8)
                
                amountField(title: "Enter the amount", text: $fromAmount)
                pickerCrypto
                Image(systemName: "arrow.up.arrow.down").font(.title2)
                amountField(title: "Enter the amount", text: $toAmount, disabled: true)
                pickerFiat
                
                if let errorMessage { Text(errorMessage).foregroundStyle(.red).font(.caption) }
                
                historySection
            }
            .padding(16)
            .padding(.top, topSafeAreaInset + 8)
        }
        .background(Color(.systemGroupedBackground))
        .onChange(of: fromAmount) { _ in recalc() }
        .onChange(of: fromCrypto) { _ in recalc() }
        .onChange(of: toFiat) { _ in recalc() }
        .onAppear {
            recalc()
            topSafeAreaInset = Self.currentTopSafeAreaInset()
        }
    }
    
    private func amountField(title: String, text: Binding<String>, disabled: Bool = false) -> some View {
        TextField(title, text: text)
            .keyboardType(.decimalPad)
            .disabled(disabled)
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.3)))
    }
    
    private var pickerCrypto: some View {
        Menu {
            ForEach(Crypto.allCases, id: \.self) { c in
                Button(c.rawValue) { fromCrypto = c }
            }
        } label: {
            HStack {
                Text(fromCrypto.rawValue)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        }
    }
    
    private var pickerFiat: some View {
        Menu {
            ForEach(Fiat.allCases, id: \.self) { f in
                Button(f.rawValue) { toFiat = f }
            }
        } label: {
            HStack {
                Text(toFiat.rawValue)
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        }
    }
    
    private func recalc() {
        errorMessage = nil
        guard let input = Double(fromAmount.replacingOccurrences(of: ",", with: ".")) else {
            toAmount = ""
            return
        }
        guard let usdPrice = ratesStore.price(crypto: fromCrypto.rawValue, fiat: "USD") else {
            errorMessage = "There is no current rate. Update Prices."
            toAmount = ""
            return
        }
        let usdValue = input * usdPrice
        let rateUSDToFiat = fiatRate(fromUSDTo: toFiat)
        let result = usdValue * rateUSDToFiat
        toAmount = format(result, currency: toFiat.rawValue)
        saveToHistory(amount: input, crypto: fromCrypto, result: result, fiat: toFiat)
    }
    
    private func fiatRate(fromUSDTo fiat: Fiat) -> Double {
        switch fiat {
        case .USD: return 1
        case .EUR: return 0.92 // упрощенно; можно заменить на системные курсы при желании
        case .RUB: return 90
        }
    }
    
    private func format(_ value: Double, currency: String) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currency
        f.maximumFractionDigits = value < 1 ? 6 : 2
        return f.string(from: NSNumber(value: value)) ?? "0"
    }
    
    private func saveToHistory(amount: Double, crypto: Crypto, result: Double, fiat: Fiat) {
        let entry = Conversion(ts: Date(), amount: amount, crypto: crypto.rawValue, result: result, fiat: fiat.rawValue)
        history.insert(entry, at: 0)
        history = Array(history.prefix(5))
        ConversionStorage.save(history)
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("History").font(.title3.weight(.semibold)).foregroundStyle(.blue)
                Spacer()
            }
            ForEach(history) { item in
                Button {
                    fromAmount = String(item.amount)
                    fromCrypto = Crypto(rawValue: item.crypto) ?? .BTC
                    toFiat = Fiat(rawValue: item.fiat) ?? .USD
                    recalc()
                } label: {
                    HStack {
                        Text(String(format: "%.0f", item.amount)).foregroundStyle(.blue)
                        Text(item.crypto).foregroundStyle(.primary)
                        Image(systemName: "arrow.right")
                        Text(format(item.result, currency: item.fiat)).foregroundStyle(.blue)
                        Text(item.fiat)
                    }
                }
                Divider()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20).fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, y: 2)
        )
    }
}

// MARK: - History storage

private struct Conversion: Identifiable, Codable {
    let id = UUID()
    let ts: Date
    let amount: Double
    let crypto: String
    let result: Double
    let fiat: String
}

private enum ConversionStorage {
    static let key = "calc.history.v1"
    
    static func load() -> [Conversion] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let items = try? JSONDecoder().decode([Conversion].self, from: data) else { return [] }
        return items
    }
    
    static func save(_ items: [Conversion]) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

#Preview {
    CalculatorView()
}

// MARK: - Helpers

extension CalculatorView {
    static func currentTopSafeAreaInset() -> CGFloat {
        let scenes = UIApplication.shared.connectedScenes
        let windows = scenes.compactMap { $0 as? UIWindowScene }.flatMap { $0.windows }
        return windows.first(where: { $0.isKeyWindow })?.safeAreaInsets.top ?? 0
    }
}


