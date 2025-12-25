//
//  Purchase.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 24.12.2025.
//

import Foundation
import SwiftUI

enum PurchaseStatus: String, Codable {
    case activeWarranty      // Гарантия больше 5 дней
    case expiresSoon         // Гарантия 5 дней или меньше
    case outOfWarranty       // Гарантия закончилась
    case returned            // Товар возвращен
}

struct Purchase: Identifiable, Codable {
    let id: UUID
    var name: String
    var shop: String
    var purchaseDate: Date
    var warrantyMonths: Int
    var isLifetimeWarranty: Bool
    var photoData: Data?
    var pdfURL: String?
    var isReturned: Bool
    
    init(id: UUID = UUID(),
         name: String,
         shop: String,
         purchaseDate: Date,
         warrantyMonths: Int,
         isLifetimeWarranty: Bool = false,
         photoData: Data? = nil,
         pdfURL: String? = nil,
         isReturned: Bool = false) {
        self.id = id
        self.name = name
        self.shop = shop
        self.purchaseDate = purchaseDate
        self.warrantyMonths = warrantyMonths
        self.isLifetimeWarranty = isLifetimeWarranty
        self.photoData = photoData
        self.pdfURL = pdfURL
        self.isReturned = isReturned
    }
    
    // Дата окончания гарантии
    var warrantyEndDate: Date {
        if isLifetimeWarranty {
            return Calendar.current.date(byAdding: .year, value: 100, to: purchaseDate) ?? purchaseDate
        }
        return Calendar.current.date(byAdding: .month, value: warrantyMonths, to: purchaseDate) ?? purchaseDate
    }
    
    // Дней до окончания гарантии
    var daysUntilWarrantyExpires: Int {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: warrantyEndDate).day ?? 0
        return max(0, days)
    }
    
    // Статус покупки
    var status: PurchaseStatus {
        if isReturned {
            return .returned
        }
        
        let daysLeft = daysUntilWarrantyExpires
        
        if daysLeft == 0 && !isLifetimeWarranty {
            return .outOfWarranty
        } else if daysLeft <= 5 && !isLifetimeWarranty {
            return .expiresSoon
        } else {
            return .activeWarranty
        }
    }
    
    // Цвет статуса
    var statusColor: String {
        switch status {
        case .activeWarranty:
            return "text_5Color"
        case .expiresSoon:
            return "text_6Color"
        case .returned:
            return "text_4Color"
        case .outOfWarranty:
            return "text_7Color"
        }
    }
    
    // Иконка статуса
    var statusIcon: String {
        switch status {
        case .activeWarranty:
            return "activeWarrantyIcon"
        case .expiresSoon:
            return "expressSoonIcon"
        case .returned:
            return "returnedIcon"
        case .outOfWarranty:
            return "outOfWarrantyIcon"
        }
    }
    
    // Текст статуса
    var statusText: String {
        switch status {
        case .activeWarranty:
            return "Active warranty"
        case .expiresSoon:
            return "Expires soon"
        case .returned, .outOfWarranty:
            return "Out of warranty"
        }
    }
    
    // Фото как UIImage
    var photo: UIImage? {
        guard let data = photoData else { return nil }
        return UIImage(data: data)
    }
}

