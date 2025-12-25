//
//  NotificationManager.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 25.12.2025.
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isNotificationsEnabled: Bool = false
    
    private init() {
        checkNotificationStatus()
    }
    
    // MARK: - Запрос разрешения на уведомления
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = granted
                completion(granted)
            }
        }
    }
    
    // MARK: - Проверка статуса уведомлений
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Планирование уведомления для товара
    func scheduleWarrantyNotification(for purchase: Purchase, daysBeforeExpiry: Int = 7) {
        // Удаляем старое уведомление для этого товара
        removeNotification(for: purchase)
        
        // Не планируем для возвращённых или с пожизненной гарантией
        guard !purchase.isReturned && !purchase.isLifetimeWarranty else { return }
        
        // Рассчитываем дату уведомления (за N дней до истечения гарантии)
        guard let notificationDate = Calendar.current.date(byAdding: .day, value: -daysBeforeExpiry, to: purchase.warrantyEndDate) else { return }
        
        // Не планируем уведомления в прошлом
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Warranty Expiring Soon!"
        content.body = "\(purchase.name) warranty expires in \(daysBeforeExpiry) days. Consider returning or checking the product."
        content.sound = .default
        content.badge = 1
        
        // Создаём триггер на конкретную дату
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Создаём запрос
        let request = UNNotificationRequest(
            identifier: "warranty_\(purchase.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Добавляем уведомление
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(purchase.name) on \(notificationDate)")
            }
        }
    }
    
    // MARK: - Планирование уведомлений для всех товаров
    func scheduleNotificationsForAllPurchases() {
        let purchases = PurchaseManager.shared.purchases
        
        for purchase in purchases {
            // Уведомление за 7 дней до истечения
            scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 7)
            // Уведомление за 3 дня до истечения
            scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 3)
            // Уведомление за 1 день до истечения
            scheduleWarrantyNotification(for: purchase, daysBeforeExpiry: 1)
        }
    }
    
    // MARK: - Удаление уведомления для товара
    func removeNotification(for purchase: Purchase) {
        let identifiers = [
            "warranty_\(purchase.id.uuidString)",
            "warranty_7_\(purchase.id.uuidString)",
            "warranty_3_\(purchase.id.uuidString)",
            "warranty_1_\(purchase.id.uuidString)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Удаление всех уведомлений
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Сброс badge
    func resetBadge() {
        if #available(iOS 16.0, *) {
            UNUserNotificationCenter.current().setBadgeCount(0) { error in
                if let error = error {
                    print("Error resetting badge: \(error)")
                }
            }
        } else {
            DispatchQueue.main.async {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
    }
    
}

