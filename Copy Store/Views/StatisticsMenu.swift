//
//  StatisticsMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct StatisticsMenu: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @State private var isMonthSelected: Bool = true
    @Namespace private var dateAnimation
    
    // Фильтрованные покупки по периоду
    var filteredPurchases: [Purchase] {
        let calendar = Calendar.current
        let now = Date()
        
        return purchaseManager.purchases.filter { purchase in
            if isMonthSelected {
                // Текущий месяц
                return calendar.isDate(purchase.purchaseDate, equalTo: now, toGranularity: .month)
            } else {
                // Текущий год
                return calendar.isDate(purchase.purchaseDate, equalTo: now, toGranularity: .year)
            }
        }
    }
    
    // Активные гарантии (больше 5 дней)
    var activeGuarantees: Int {
        filteredPurchases.filter { $0.status == .activeWarranty }.count
    }
    
    // Истекающие гарантии (5 дней и меньше)
    var expiresSoon: Int {
        filteredPurchases.filter { $0.status == .expiresSoon }.count
    }
    
    // Истекшие гарантии
    var expiredGuarantees: Int {
        filteredPurchases.filter { $0.status == .outOfWarranty }.count
    }
    
    // Уже возвращено
    var alreadyReturned: Int {
        filteredPurchases.filter { $0.isReturned }.count
    }
    
    // Доступно для возврата (14 дней от покупки)
    var returnAvailable: Int {
        filteredPurchases.filter { purchase in
            !purchase.isReturned &&
            Calendar.current.dateComponents([.day], from: purchase.purchaseDate, to: Date()).day ?? 0 <= 14
        }.count
    }
    
    // Общее количество товаров
    var totalItems: Int {
        filteredPurchases.count
    }
    
    // Процент для insight (возвращено от общего)
    var insightPercent: Int {
        guard totalItems > 0 else { return 0 }
        return (alreadyReturned * 100) / totalItems
    }
    
    var percentImage: String {
        switch insightPercent {
        case 0..<13: return "percent0"
        case 13..<38: return "percent25"
        case 38..<63: return "percent50"
        case 63..<88: return "percent75"
        default: return "percent100"
        }
    }
    
    // Заголовок для insight
    var insightTitle: String {
        switch insightPercent {
        case 0..<13:
            return "Just starting!"
        case 13..<38:
            return "Making progress!"
        case 38..<63:
            return "Halfway there!"
        case 63..<88:
            return "Great job!"
        default:
            return "Amazing!"
        }
    }
    
    // Описание для insight
    var insightDescription: String {
        switch insightPercent {
        case 0..<13:
            if totalItems == 0 {
                return "Add your first purchase to start tracking warranties."
            }
            return "You returned \(alreadyReturned) of \(totalItems) items. There's room to improve!"
        case 13..<38:
            return "You returned \(alreadyReturned) of \(totalItems) items. Keep tracking your purchases!"
        case 38..<63:
            return "You returned \(alreadyReturned) of \(totalItems) items. You're doing well!"
        case 63..<88:
            return "You returned \(alreadyReturned) of \(totalItems) items. Keep it up!"
        default:
            return "You returned \(alreadyReturned) of \(totalItems) items. Outstanding work!"
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: screenHeight * 0.02) {
                // Header
                Text("Statistics")
                    .font(.custom("SF Pro Display", size: screenHeight * 0.028))
                    .foregroundColor(Color("text_2Color"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // Date selector
                dateSelector
                
                // Insight section
                insightSection
                
                // Guarantees section
                guaranteesSection
                
                // Refunds section
                refundsSection
            }
            .padding(.horizontal, screenWidth * 0.05)
            .padding(.top, screenHeight * 0.02)
        }
    }
    
    // MARK: - Date Selector
    private var dateSelector: some View {
        ZStack {
            Image("dateFrame")
                .resizable()
                .scaledToFit()
            
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isMonthSelected = true
                    }
                }) {
                    ZStack {
                        if isMonthSelected {
                            Image("activeDateFrame")
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: "dateSelector", in: dateAnimation)
                        }
                        
                        Text("Month")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                            .foregroundColor(isMonthSelected ? .black : Color("text_3Color"))
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isMonthSelected = false
                    }
                }) {
                    ZStack {
                        if !isMonthSelected {
                            Image("activeDateFrame")
                                .resizable()
                                .scaledToFit()
                                .matchedGeometryEffect(id: "dateSelector", in: dateAnimation)
                        }
                        
                        Text("Year")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                            .foregroundColor(!isMonthSelected ? .black : Color("text_3Color"))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, screenWidth * 0.02)
        }
        .frame(height: screenHeight * 0.055)
    }
    
    // MARK: - Insight Section
    private var insightSection: some View {
        ZStack(alignment: .topLeading) {
            Image("insightFrame")
                .resizable()
                .scaledToFit()
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: screenHeight * 0.01) {
                    HStack(spacing: screenWidth * 0.02) {
                        Image("insightIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.025)
                        
                        Text("INSIGHT")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_3Color"))
                    }
                    
                    Text(insightTitle)
                        .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text(insightDescription)
                        .font(.custom("SF Pro Display", size: screenHeight * 0.014))
                        .foregroundColor(Color("text_3Color"))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: screenWidth * 0.5, alignment: .leading)
                
                Spacer()
                
                Image(percentImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight * 0.09)
            }
            .padding(.horizontal, screenWidth * 0.04)
            .padding(.top, screenHeight * 0.015)
        }
    }
    
    // MARK: - Guarantees Section
    private var guaranteesSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.015) {
            Text("Guarantees")
                .font(.custom("SF Pro Display", size: screenHeight * 0.024))
                .foregroundColor(Color("text_2Color"))
            
            HStack(spacing: screenWidth * 0.03) {
                // Active guarantees
                ZStack {
                    Image("guaranteesFrame")
                        .resizable()
                        .scaledToFit()
                    
                    HStack(spacing: screenWidth * 0.02) {
                        Image("activeIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.05)
                        
                        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                            Text("Active")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("\(activeGuarantees + expiresSoon)")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                                .foregroundColor(Color.black)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                }
                
                // Expired guarantees
                ZStack {
                    Image("guaranteesFrame")
                        .resizable()
                        .scaledToFit()
                    
                    HStack(spacing: screenWidth * 0.02) {
                        Image("expiredIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.05)
                        
                        VStack(alignment: .leading, spacing: screenHeight * 0.005) {
                            Text("Expired")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("\(expiredGuarantees)")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                                .foregroundColor(Color.black)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                }
            }
        }
    }
    
    // MARK: - Refunds Section
    private var refundsSection: some View {
        VStack(alignment: .leading, spacing: screenHeight * 0.015) {
            Text("Refunds")
                .font(.custom("SF Pro Display", size: screenHeight * 0.024))
                .foregroundColor(Color("text_2Color"))
            
            ZStack(alignment: .leading) {
                Image("insightFrame")
                    .resizable()
                    .scaledToFit()
                
                VStack(spacing: screenHeight * 0.015) {
                    // Already returned row
                    HStack {
                        Image("alreadyReturnedIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.035)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Already returned")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("Completed refunds")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.013))
                                .foregroundColor(Color("text_3Color"))
                        }
                        
                        Spacer()
                        
                        Text("\(alreadyReturned)")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                            .foregroundColor(Color.black)
                    }
                    
                    // Return available row
                    HStack {
                        Image("returnAvalibleIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.035)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Return available")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("Within 14 days")
                                .font(.custom("SF Pro Display", size: screenHeight * 0.013))
                                .foregroundColor(Color("text_3Color"))
                        }
                        
                        Spacer()
                        
                        Text("\(returnAvailable)")
                            .font(.custom("SF Pro Display", size: screenHeight * 0.022))
                            .foregroundColor(Color.black)
                    }
                }
                .padding(.horizontal, screenWidth * 0.04)
                .padding(.vertical, screenHeight * 0.015)
            }
        }
    }
}

#Preview {
    StatisticsMenu()
}

