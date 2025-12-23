//
//  MainMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct MainMenu: View {
    @State private var purchases: [String] = [] // Пока пустой массив, добавим модель позже
    
    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            // Header
            HStack {
                Text("My purchases")
                    .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.028))
                    .foregroundColor(Color("text_2Color"))
                
                Spacer()
                
                Button(action: {
                    // Добавление покупки - добавим позже
                }) {
                    Image("plusButton")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                }
            }
            .padding(.horizontal, screenWidth * 0.05)
            
            // Filter buttons
            HStack(spacing: screenWidth * 0.03) {
                Button(action: {
                    // Expires filter
                }) {
                    Image("expiresButton")
                        .resizable()
                        .scaledToFit()
                }
                
                Button(action: {
                    // Archive filter
                }) {
                    Image("archiveButton")
                        .resizable()
                        .scaledToFit()
                }
                
                Button(action: {
                    // Refund filter
                }) {
                    Image("refundButton")
                        .resizable()
                        .scaledToFit()
                }
            }
            .frame(height: screenHeight * 0.045)
            .padding(.horizontal, screenWidth * 0.05)
            
            // Purchases list or empty state
            if purchases.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.01) {
                    Image("addOneIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("Add your first one")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.03))
                        .foregroundColor(Color("text_2Color"))
                    
                    Text("Your products will")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                    
                    Text("appear here")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                }
                
                Spacer()
            } else {
                ScrollView {
                    // Покупки добавим позже
                }
            }
            
            Spacer()
        }
        .padding(.top, screenHeight * 0.02)
    }
}

#Preview {
    MainMenu()
}
