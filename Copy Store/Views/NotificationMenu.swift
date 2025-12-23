//
//  NotificationMenu.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct NotificationMenu: View {
    @State private var notifications: [String] = [] // Пока пустой массив, добавим модель позже
    
    var body: some View {
        VStack(spacing: screenHeight * 0.02) {
            // Header
            Text("Notification")
                .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.028))
                .foregroundColor(Color("text_2Color"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, screenWidth * 0.05)
            
            // Notifications list or empty state
            if notifications.isEmpty {
                Spacer()
                
                VStack(spacing: screenHeight * 0.01) {
                    Image("notificationIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.08)
                    
                    Text("Products nearing expiration")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.025))
                        .foregroundColor(Color("text_2Color"))
                    
                    Text("appear here")
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.025))
                        .foregroundColor(Color("text_2Color"))
                }
                .padding(.top, screenHeight*0.065)
                
                Spacer()
            } else {
                ScrollView {
                    // Уведомления добавим позже
                }
            }
            
            Spacer()
        }
        .padding(.top, screenHeight * 0.02)
    }
}

#Preview {
    NotificationMenu()
}

