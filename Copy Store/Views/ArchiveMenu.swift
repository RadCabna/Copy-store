//
//  ArchiveMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct MonthSection: Identifiable {
    let id = UUID()
    let month: String
    let year: String
    let purchases: [Purchase]
}

struct ArchiveMenu: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @State private var currentlySwipedId: UUID? = nil
    
    var returnedPurchases: [Purchase] {
        purchaseManager.purchases.filter { $0.isReturned }
    }
    
    var refundsCount: Int {
        returnedPurchases.count
    }
    
    var groupedByMonth: [MonthSection] {
        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM"
        let yearFormatter = DateFormatter()
        yearFormatter.dateFormat = "yyyy"
        
        // Группируем по месяцу и году
        let grouped = Dictionary(grouping: returnedPurchases) { purchase -> String in
            let components = calendar.dateComponents([.year, .month], from: purchase.purchaseDate)
            return "\(components.year ?? 0)-\(components.month ?? 0)"
        }
        
        // Сортируем по дате (новые сверху)
        let sorted = grouped.sorted { first, second in
            let firstParts = first.key.split(separator: "-").compactMap { Int($0) }
            let secondParts = second.key.split(separator: "-").compactMap { Int($0) }
            if firstParts[0] != secondParts[0] {
                return firstParts[0] > secondParts[0]
            }
            return firstParts[1] > secondParts[1]
        }
        
        return sorted.map { key, purchases in
            let date = purchases.first?.purchaseDate ?? Date()
            return MonthSection(
                month: monthFormatter.string(from: date),
                year: yearFormatter.string(from: date),
                purchases: purchases.sorted { $0.purchaseDate > $1.purchaseDate }
            )
        }
    }
    
    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            // Header
            Text("Archive")
                .font(.custom("SF Pro Display", size: screenHeight * 0.028))
                .foregroundColor(Color("text_2Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, screenWidth * 0.05)
            
            // Refunds counter
            ZStack {
                Image("refundsBack")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.08)
                
                HStack(spacing: screenWidth * 0.03) {
                    Image("refundThunder")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                    VStack {
                        Text("Total refunds:")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                            .foregroundColor(Color("text_2Color"))
                        Text("\(refundsCount)")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.035))
                            .foregroundColor(Color("text_2Color"))
                    }
                    Image("refundThunder")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Refunds list or empty state
            if returnedPurchases.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.01) {
                    Image("noReturnsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("No returns yet")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.03))
                        .foregroundColor(Color("text_2Color"))
                    
                    Text("Submitted returns will")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                    
                    Text("appear here")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                }
                
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.02) {
                        ForEach(groupedByMonth) { section in
                            VStack(spacing: screenHeight * 0.015) {
                                // Month header
                                HStack {
                                    Text(section.month)
                                        .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("text_3Color"))
                                    
                                    Spacer()
                                    
                                    Text(section.year)
                                        .font(.custom("SF Pro Display", size: screenHeight * 0.02))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color("text_3Color"))
                                }
                                
                                // Purchases in this month
                                ForEach(section.purchases) { purchase in
                                    ArchiveCardView(
                                        purchase: purchase,
                                        currentlySwipedId: $currentlySwipedId,
                                        onDelete: {
                                            withAnimation {
                                                purchaseManager.deletePurchase(purchase)
                                            }
                                        }
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, screenWidth * 0.05)
                }
            }
            
            Spacer()
        }
        .padding(.top, screenHeight * 0.02)
    }
}

// MARK: - Archive Card View (только удаление)
struct ArchiveCardView: View {
    let purchase: Purchase
    @Binding var currentlySwipedId: UUID?
    var onDelete: (() -> Void)? = nil
    
    @State private var offset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private let swipeThreshold: CGFloat = UIScreen.main.bounds.width * 0.25
    
    private var isSwiped: Bool {
        currentlySwipedId == purchase.id
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button (behind the card)
            HStack {
                Spacer()
                
                Button(action: {
                    withAnimation(.easeOut(duration: 0.25)) {
                        offset = -screenWidth
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onDelete?()
                    }
                }) {
                    Image("deleteIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.067)
                }
            }
            .padding(.trailing, screenWidth * 0.04)
            .opacity(offset < -20 ? 1 : 0)
            
            // Card content
            cardContent
                .offset(x: offset)
                .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0), value: offset)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 15)
                        .onChanged { value in
                            let horizontal = abs(value.translation.width)
                            let vertical = abs(value.translation.height)
                            
                            // Только если горизонтальное движение больше вертикального
                            if horizontal > vertical || isDragging {
                                isDragging = true
                                
                                if currentlySwipedId != nil && currentlySwipedId != purchase.id {
                                    currentlySwipedId = nil
                                }
                                
                                let translation = value.translation.width
                                if translation < 0 {
                                    offset = translation
                                } else if isSwiped {
                                    offset = min(0, -swipeThreshold + translation)
                                }
                            }
                        }
                        .onEnded { value in
                            if isDragging {
                                let translation = value.translation.width
                                let velocity = value.predictedEndTranslation.width - translation
                                
                                if translation < -swipeThreshold / 2 || velocity < -100 {
                                    offset = -swipeThreshold
                                    currentlySwipedId = purchase.id
                                } else {
                                    closeSwipe()
                                }
                            }
                            isDragging = false
                        }
                )
        }
        .onChange(of: currentlySwipedId) { newValue in
            if newValue != purchase.id && offset != 0 {
                offset = 0
            }
        }
    }
    
    private func closeSwipe() {
        offset = 0
        if currentlySwipedId == purchase.id {
            currentlySwipedId = nil
        }
    }
    
    private var cardContent: some View {
        ZStack {
            Image("listProductFrame")
                .resizable()
                .scaledToFit()
            
            HStack(spacing: screenWidth * 0.03) {
                // Фото товара
                Group {
                    if let photo = purchase.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(width: screenHeight * 0.08, height: screenHeight * 0.08)
                .clipShape(Circle())
                
                // Информация о товаре
                VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                    Text(purchase.name)
                        .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text("Returned: \(dateFormatter.string(from: Date()))")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.013))
                        .foregroundColor(Color("text_3Color"))
                    
                    Text("RETURNED")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.012))
                        .fontWeight(.semibold)
                        .foregroundColor(Color("text_4Color"))
                }
                .frame(width: screenWidth * 0.27)
                
                Spacer()
                
                // Иконка статуса
                Image("returnedIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.075)
            }
            .padding(.horizontal, screenWidth * 0.04)
        }
    }
}

#Preview {
    ArchiveMenu()
}

