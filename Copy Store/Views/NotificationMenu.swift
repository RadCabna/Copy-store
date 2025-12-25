//
//  NotificationMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct WarrantyNotification: Identifiable {
    var id: UUID { purchase.id }
    let purchase: Purchase
    let createdAt: Date
    
    var daysUntilExpiry: Int {
        purchase.daysUntilWarrantyExpires
    }
    
    var timeAgoText: String {
        let seconds = Int(Date().timeIntervalSince(createdAt))
        
        if seconds < 60 {
            return "Just now"
        } else if seconds < 3600 {
            let minutes = seconds / 60
            return "\(minutes) min ago"
        } else if seconds < 86400 {
            let hours = seconds / 3600
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = seconds / 86400
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }
}

// Менеджер для хранения скрытых уведомлений
class DismissedNotificationsManager: ObservableObject {
    static let shared = DismissedNotificationsManager()
    
    @Published var dismissedIds: Set<UUID> = []
    
    private let key = "dismissedNotificationIds"
    
    init() {
        loadDismissed()
    }
    
    func dismiss(_ id: UUID) {
        dismissedIds.insert(id)
        saveDismissed()
    }
    
    func isDismissed(_ id: UUID) -> Bool {
        dismissedIds.contains(id)
    }
    
    private func saveDismissed() {
        let strings = dismissedIds.map { $0.uuidString }
        UserDefaults.standard.set(strings, forKey: key)
    }
    
    private func loadDismissed() {
        if let strings = UserDefaults.standard.stringArray(forKey: key) {
            dismissedIds = Set(strings.compactMap { UUID(uuidString: $0) })
        }
    }
}

struct NotificationMenu: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @ObservedObject private var dismissedManager = DismissedNotificationsManager.shared
    @State private var currentlySwipedId: UUID? = nil
    
    // Товары с истекающей гарантией (14 дней и менее, но не возвращённые и не истёкшие)
    var expiringPurchases: [WarrantyNotification] {
        purchaseManager.purchases
            .filter { purchase in
                !purchase.isReturned &&
                purchase.daysUntilWarrantyExpires > 0 &&
                purchase.daysUntilWarrantyExpires <= 14 &&
                !purchase.isLifetimeWarranty &&
                !dismissedManager.isDismissed(purchase.id)
            }
            .sorted { $0.daysUntilWarrantyExpires < $1.daysUntilWarrantyExpires }
            .map { purchase in
                WarrantyNotification(
                    purchase: purchase,
                    createdAt: Calendar.current.date(
                        byAdding: .day,
                        value: -(14 - purchase.daysUntilWarrantyExpires),
                        to: Date()
                    ) ?? Date()
                )
            }
    }
    
    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            // Header
            Text("Notification")
                .font(.custom("SF Pro Display", size: screenHeight * 0.028))
                .foregroundColor(Color("text_2Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, screenWidth * 0.05)
            
            // Notifications list or empty state
            if expiringPurchases.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.01) {
                    Image("notificationIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("Products nearing expiration")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.025))
                        .foregroundColor(Color("text_2Color"))
                    
                    Text("appear here")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.025))
                        .foregroundColor(Color("text_2Color"))
                }
                .padding(.top, screenHeight * 0.065)
                
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: screenHeight * 0.015) {
                        ForEach(expiringPurchases) { notification in
                            NotificationCardView(
                                notification: notification,
                                currentlySwipedId: $currentlySwipedId,
                                onDismiss: {
                                    withAnimation {
                                        dismissedManager.dismiss(notification.purchase.id)
                                    }
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
    }
}

// MARK: - Notification Card View
struct NotificationCardView: View {
    let notification: WarrantyNotification
    @Binding var currentlySwipedId: UUID?
    var onDismiss: (() -> Void)? = nil
    
    @State private var offset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    private let swipeThreshold: CGFloat = UIScreen.main.bounds.width * 0.25
    
    private var isSwiped: Bool {
        currentlySwipedId == notification.id
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
                        onDismiss?()
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
                            
                            if horizontal > vertical || isDragging {
                                isDragging = true
                                
                                if currentlySwipedId != nil && currentlySwipedId != notification.id {
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
                                    currentlySwipedId = notification.id
                                } else {
                                    closeSwipe()
                                }
                            }
                            isDragging = false
                        }
                )
        }
        .onChange(of: currentlySwipedId) { newValue in
            if newValue != notification.id && offset != 0 {
                offset = 0
            }
        }
    }
    
    private func closeSwipe() {
        offset = 0
        if currentlySwipedId == notification.id {
            currentlySwipedId = nil
        }
    }
    
    private var cardContent: some View {
        ZStack {
            Image("notificationFrame")
                .resizable()
                .scaledToFit()
            
            HStack(spacing: screenWidth * 0.03) {
                Image("warningIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.04)
                
                VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                    Text(notification.purchase.name)
                        .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text("Warranty expires in \(notification.daysUntilExpiry) day\(notification.daysUntilExpiry == 1 ? "" : "s")")
                        .font(.custom("SF Pro Display", size: screenHeight * 0.014))
                        .foregroundColor(Color("text_3Color"))
                }
                
                Spacer()
                
                Text(notification.timeAgoText)
                    .font(.custom("SF Pro Display", size: screenHeight * 0.012))
                    .foregroundColor(Color("text_3Color"))
            }
            .padding(.horizontal, screenWidth * 0.04)
        }
    }
}

#Preview {
    NotificationMenu()
}

