//
//  ArchiveMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct ArchiveMenu: View {
    @State private var refunds: [String] = [] // Пока пустой массив, добавим модель позже
    
    var refundsCount: Int {
        refunds.count
    }
    
    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            // Header
            Text("Archive")
                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.028))
                .foregroundColor(Color("text_2Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, screenWidth * 0.05)
            
            // Refunds counter
            ZStack {
                Image("refundsBack")
                    .resizable()
                    .scaledToFit()
                    .frame(height: screenHeight*0.08)
                
                HStack(spacing: screenWidth * 0.03) {
                    Image("refundThunder")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                    VStack {
                        
                        Text("Total refunds:")
                            .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.02))
                            .foregroundColor(Color("text_2Color"))
                    Text("\(refundsCount)")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.035))
                        .foregroundColor(Color("text_2Color"))
                }
                    Image("refundThunder")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.05)
                }
            }
            .frame(height: screenHeight * 0.06)
            .padding(.horizontal, screenWidth * 0.05)
            
            // Refunds list or empty state
            if refunds.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.01) {
                    Image("noReturnsIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("No returns yet")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.03))
                        .foregroundColor(Color("text_2Color"))
                    
                    Text("Submitted returns will")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                    
                    Text("appear here")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.02))
                        .foregroundColor(Color("text_3Color"))
                }
                
                Spacer()
            } else {
                ScrollView {
                    // Возвраты добавим позже
                }
            }
            
            Spacer()
        }
        .padding(.top, screenHeight * 0.02)
    }
}

#Preview {
    ArchiveMenu()
}

