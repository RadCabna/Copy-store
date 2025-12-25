//
//  MainMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

enum PurchaseFilter: Int {
    case recent = 0      // По дате добавления (новые сверху)
    case active = 1      // Сначала активные
    case refund = 2      // Сначала возвращённые
}

struct MainMenu: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @State private var showAddPurchase: Bool = false
    @State private var currentlySwipedId: UUID? = nil
    @State private var selectedFilter: PurchaseFilter = .recent
    
    var filteredPurchases: [Purchase] {
        switch selectedFilter {
        case .recent:
            // По дате добавления (новые сверху)
            return purchaseManager.purchases.sorted { $0.purchaseDate > $1.purchaseDate }
        case .active:
            // Сначала активные (с действующей гарантией)
            return purchaseManager.purchases.sorted { first, second in
                let firstActive = first.status == .activeWarranty || first.status == .expiresSoon
                let secondActive = second.status == .activeWarranty || second.status == .expiresSoon
                if firstActive != secondActive {
                    return firstActive
                }
                return first.purchaseDate > second.purchaseDate
            }
        case .refund:
            // Сначала возвращённые
            return purchaseManager.purchases.sorted { first, second in
                if first.isReturned != second.isReturned {
                    return first.isReturned
                }
                return first.purchaseDate > second.purchaseDate
            }
        }
    }
    
    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            // Header
            HStack {
                Text("My purchases")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.028))
                    .foregroundColor(Color("text_2Color"))
                
                Spacer()
                
                Button(action: {
                    showAddPurchase = true
                }) {
                    Image("plusButton")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Filter buttons
            HStack(spacing: screenWidth * 0.02) {
                filterButton(
                    iconOn: "calendarIconOff",
                    iconOff: "calendarIconOn",
                    text: "Expires this month",
                    filter: .recent,
                    widthMultiplier: 1.3
                )
                
                filterButton(
                    iconOn: "calendarIconOff",
                    iconOff: "calendarIconOn",
                    text: "Active",
                    filter: .active,
                    widthMultiplier: 0.85
                )
                
                filterButton(
                    iconOn: "calendarIconOff",
                    iconOff: "calendarIconOn",
                    text: "Refund",
                    filter: .refund,
                    widthMultiplier: 0.85
                )
            }
            .frame(width: screenWidth * 0.9)
            
            // Purchases list or empty state
            if purchaseManager.purchases.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.01) {
                    Image("addOneIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("Add your first one")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.03))
                        .foregroundColor(Color("text_2Color"))
                    
                    Text("Your products will")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                    
                    Text("appear here")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                }
                
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.015) {
                        ForEach(filteredPurchases) { purchase in
                            ProductCardView(
                                purchase: purchase,
                                currentlySwipedId: $currentlySwipedId,
                                onDelete: {
                                    withAnimation {
                                        purchaseManager.deletePurchase(purchase)
                                    }
                                },
                                onReturn: {
                                    purchaseManager.markAsReturned(purchase)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                }
            }
            
            Spacer()
        }
        .padding(.top, screenHeight * 0.02)
        .fullScreenCover(isPresented: $showAddPurchase) {
            AddPurchaseView()
        }
    }
    
    // MARK: - Filter Button
    private func filterButton(iconOn: String, iconOff: String, text: String, filter: PurchaseFilter, widthMultiplier: CGFloat = 1.0) -> some View {
        let isSelected = selectedFilter == filter
        // Общая ширина 0.9, промежутки 0.04. Первая кнопка шире (1.4), остальные уже (0.8)
        let totalWidth = screenWidth * 0.9 - screenWidth * 0.04
        let baseWidth = totalWidth / 3
        let buttonWidth = baseWidth * widthMultiplier
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedFilter = filter
            }
        }) {
            HStack(spacing: screenWidth * 0.015) {
                Image(isSelected ? iconOn : iconOff)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.022)
                
                Text(text)
                    .font(.custom("SF Pro Display", size: screenHeight * 0.014))
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .foregroundColor(isSelected ? Color("text_2Color") : .black)
            .frame(width: buttonWidth, height: screenHeight * 0.045)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color("text_4Color") : .white)
            )
        }
    }
}

#Preview {
    MainMenu()
}
