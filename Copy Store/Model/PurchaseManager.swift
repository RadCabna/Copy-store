//
//  PurchaseManager.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 24.12.2025.
//

import Foundation
import SwiftUI

class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()
    
    @Published var purchases: [Purchase] = []
    
    private let purchasesKey = "savedPurchases"
    
    init() {
        loadPurchases()
    }
    
    func addPurchase(_ purchase: Purchase) {
        purchases.append(purchase)
        savePurchases()
        
        // Планируем уведомления для нового товара
        NotificationManager.shared.scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 7)
        NotificationManager.shared.scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 3)
        NotificationManager.shared.scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 1)
    }
    
    func updatePurchase(_ purchase: Purchase) {
        if let index = purchases.firstIndex(where: { $0.id == purchase.id }) {
            purchases[index] = purchase
            savePurchases()
            
            // Перепланируем уведомления
            NotificationManager.shared.scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 7)
            NotificationManager.shared.scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 3)
            NotificationManager.shared.scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 1)
        }
    }
    
    func deletePurchase(_ purchase: Purchase) {
        // Удаляем уведомления для товара
        NotificationManager.shared.removeNotification(for: purchase)
        
        purchases.removeAll { $0.id == purchase.id }
        savePurchases()
    }
    
    func markAsReturned(_ purchase: Purchase) {
        if let index = purchases.firstIndex(where: { $0.id == purchase.id }) {
            purchases[index].isReturned = true
            savePurchases()
            
            // Удаляем уведомления для возвращённого товара
            NotificationManager.shared.removeNotification(for: purchases[index])
        }
    }
    
    private func savePurchases() {
        if let encoded = try? JSONEncoder().encode(purchases) {
            UserDefaults.standard.set(encoded, forKey: purchasesKey)
        }
    }
    
    private func loadPurchases() {
        if let data = UserDefaults.standard.data(forKey: purchasesKey),
           let decoded = try? JSONDecoder().decode([Purchase].self, from: data) {
            purchases = decoded
        }
    }
}

