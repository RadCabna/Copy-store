//
//  StatisticsMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct StatisticsMenu: View {
    @State private var isMonthSelected: Bool = true
    @Namespace private var dateAnimation
    
    // Тестовые данные - заменим на реальные позже
    @State private var activeGuarantees: Int = 0
    @State private var expiredGuarantees: Int = 0
    @State private var alreadyReturned: Int = 0
    @State private var returnAvailable: Int = 0
    
    var insightPercent: Int {
        let total = activeGuarantees + expiredGuarantees
        guard total > 0 else { return 0 }
        return (activeGuarantees * 100) / total
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
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: screenHeight * 0.02) {
                // Header
                Text("Statistics")
                    .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.028))
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
                            .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.018))
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
                            .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.018))
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
            
            HStack {
                VStack{
                    HStack(spacing: screenWidth * 0.02) {
                        Image("insightIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(height: screenHeight * 0.025)
                        
                        Text("INSIGHT")
                            .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.018))
                            .foregroundColor(Color("text_3Color"))
                    }
                    Spacer()
                }
                
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
                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.024))
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
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("\(activeGuarantees)")
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.022))
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
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("\(expiredGuarantees)")
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.022))
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
                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.024))
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
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("Expires soon")
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.013))
                                .foregroundColor(Color("text_3Color"))
                        }
                        
                        Spacer()
                        
                        Text("\(alreadyReturned)")
                            .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.022))
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
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.016))
                                .foregroundColor(Color("text_3Color"))
                            
                            Text("Completed")
                                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.013))
                                .foregroundColor(Color("text_3Color"))
                        }
                        
                        Spacer()
                        
                        Text("\(returnAvailable)")
                            .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.022))
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

