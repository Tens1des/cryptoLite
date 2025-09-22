//
//  MainTabContainerView.swift
//  CryptoLite
//
//  Created by AI Assistant on 22.09.2025.
//

import SwiftUI

/// Вкладки приложения
private enum AppTab: CaseIterable, Hashable {
    case articles
    case rates
    case calculator
    case education
    case glossary
    case favorites
    
    var title: String {
        switch self {
        case .articles: return "Articles"
        case .rates: return "Rates"
        case .calculator: return "Calculator"
        case .education: return "Edu"
        case .glossary: return "Glossary"
        case .favorites: return "Favorites"
        }
    }
    
    /// Имена иконок из ассетов, как указал пользователь
    var imageName: String {
        switch self {
        case .articles: return "articles_icon"
        case .rates: return "rates_icon"
        case .calculator: return "calculator_icon"
        case .education: return "edu_icon"
        case .glossary: return "glossary_icon"
        case .favorites: return "favorites_icon"
        }
    }
}

struct MainTabContainerView: View {
    @State private var selected: AppTab = .articles
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selected {
                case .articles:
                    ArticlesView()
                case .rates:
                    RatesView()
                case .calculator:
                    CalculatorView()
                case .education:
                    EducationView()
                case .glossary:
                    GlossaryView()
                case .favorites:
                    FavoritesView()
                }
            }
            .ignoresSafeArea()
            
            CustomTabBar(selected: $selected)
        }
    }
}

// MARK: - Custom Tab Bar

private struct CustomTabBar: View {
    @Binding var selected: AppTab
    
    private let barCornerRadius: CGFloat = 22
    private let barHorizontalPadding: CGFloat = 16
    private let barVerticalPadding: CGFloat = 4
    private let whitePanelHeight: CGFloat = 58
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Белая панель под таб-баром
            UnevenRoundedRectangle(
                topLeadingRadius: 20,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 20
            )
            .fill(Color.white)
            .frame(height: whitePanelHeight)
            .shadow(color: Color.black.opacity(0.05), radius: 8, y: -2)
            .ignoresSafeArea(edges: .bottom)

            // Сам таб-бар (уменьшенный)
            HStack(spacing: 10) {
                ForEach(AppTab.allCases, id: \.self) { tab in
                    TabItem(tab: tab, isSelected: tab == selected) {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.9)) {
                            selected = tab
                        }
                    }
                }
            }
            .padding(.horizontal, barHorizontalPadding)
            .padding(.vertical, barVerticalPadding)
            .background(
                RoundedRectangle(cornerRadius: barCornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: barCornerRadius, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 6)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private struct TabItem: View {
    let tab: AppTab
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(tab.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .padding(6)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue.opacity(0.15) : Color.clear)
                    )
                    .foregroundStyle(isSelected ? Color.blue : Color.secondary)

                Text(tab.title)
                    .font(.system(size: 5, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.white : Color.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Group {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(Color.blue)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

// MARK: - Placeholders

private struct PlaceholderScreen: View {
    let title: String
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            Text(title)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabContainerView()
}


