//
//  ProductCardView.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 24.12.2025.
//

import SwiftUI

struct ProductCardView: View {
    let purchase: Purchase
    @Binding var currentlySwipedId: UUID?
    var onDelete: (() -> Void)? = nil
    var onReturn: (() -> Void)? = nil
    
    @State private var offset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private let swipeThreshold: CGFloat = UIScreen.main.bounds.width * 0.33
    
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
            // Action buttons (behind the card)
            HStack(spacing: screenWidth * 0.03) {
                Spacer()
                
                // Return button
                Button(action: {
                    closeSwipe()
                    onReturn?()
                }) {
                    Image("returnIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.067)
                }
                
                // Delete button
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
                                
                                // Закрываем другие карточки при начале свайпа
                                if currentlySwipedId != nil && currentlySwipedId != purchase.id {
                                    currentlySwipedId = nil
                                }
                                
                                let translation = value.translation.width
                                if translation < 0 {
                                    // Свайп влево
                                    offset = translation
                                } else if isSwiped {
                                    // Свайп вправо когда уже открыто
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
                productPhoto
                
                // Информация о товаре
                productInfo
                    .frame(width: screenWidth*0.27)
                
                Spacer()
                
                // Плашка с днями
                daysBadge
                    .offset(y: -screenHeight*0.02)
                
                // Иконка статуса
                Image(purchase.statusIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.075)
            }
            .padding(.horizontal, screenWidth * 0.04)
        }
    }
    
    // MARK: - Product Photo
    private var productPhoto: some View {
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
    }
    
    // MARK: - Product Info
    private var productInfo: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
            // Название товара
            Text(purchase.name)
                .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .lineLimit(1)
            
            // Дата покупки или окончания гарантии
            if purchase.status == .outOfWarranty || purchase.status == .returned {
                Text("Out of warranty: \(dateFormatter.string(from: purchase.warrantyEndDate))")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.013))
                    .foregroundColor(Color("text_3Color"))
            } else {
                Text("Purchased: \(dateFormatter.string(from: purchase.purchaseDate))")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.013))
                    .foregroundColor(Color("text_3Color"))
            }
            
            // Статус
            Text(purchase.statusText.uppercased())
                .font(.custom("SF Pro Display", size: screenHeight * 0.009))
                .fontWeight(.semibold)
                .foregroundColor(Color(purchase.statusColor))
        }
    }
    
    
    
    // MARK: - Days Badge
    private var daysBadge: some View {
        ZStack {
            if purchase.status == .returned {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(purchase.statusColor))
                    .frame(width: screenWidth * 0.10, height: screenHeight * 0.02)
                
                Text("Returned")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.009))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
            } else if purchase.status == .outOfWarranty {
                Circle()
                    .fill(Color(purchase.statusColor))
                    .frame(width: screenHeight * 0.028, height: screenHeight * 0.028)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(purchase.statusColor))
                    .frame(width: screenWidth * 0.10, height: screenHeight * 0.02)
                
                Text("\(purchase.daysUntilWarrantyExpires) days")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.009))
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    ProductCardView(
        purchase: Purchase(
            name: "iPhone 15 Pro",
            shop: "Apple Store",
            purchaseDate: Date(),
            warrantyMonths: 12
        ),
        currentlySwipedId: .constant(nil)
    )
}

