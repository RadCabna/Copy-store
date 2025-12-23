//
//  ContentView.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedMenu: Int = 0
    @Namespace private var animation
    
    let menuItems = [
        ("menu_1", "Main"),
        ("menu_2", "Archive"),
        ("menu_3", "Notification"),
        ("menu_4", "Statistics")
    ]
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            VStack {
                // Content area
                Group {
                    switch selectedMenu {
                    case 0:
                        MainMenu()
                    case 1:
                        ArchiveMenu()
                    case 2:
                        NotificationMenu()
                    case 3:
                        StatisticsMenu()
                    default:
                        MainMenu()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
                
                // Bottom Bar
                bottomBar
                    .padding(.bottom, screenHeight * 0.02)
            }
        }
    }
    
    private var bottomBar: some View {
        ZStack {
            Image("bottomBarBack")
                .resizable()
                .scaledToFit()
                .frame(width: screenWidth * 0.9)
            
            HStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { index in
                    menuButton(index: index)
                }
            }
            .frame(width: screenWidth * 0.85)
        }
    }
    
    private func menuButton(index: Int) -> some View {
        let isSelected = selectedMenu == index
        let iconName = isSelected ? "\(menuItems[index].0)On" : "\(menuItems[index].0)Off"
        
        return Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedMenu = index
            }
        }) {
            ZStack {
                if isSelected {
                    Image("selectedMenu")
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight*0.055)
                        .matchedGeometryEffect(id: "selectedBackground", in: animation)
                }
                
                VStack(spacing: screenHeight * 0.005) {
                    Image(iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: screenHeight * 0.025)
                    
                    Text(menuItems[index].1)
                        .font(.custom("SF-Pro-Display-Semibold", size: screenHeight * 0.012))
                        .foregroundColor(isSelected ? Color("text_1Color") : .black)
                }
                .padding(.vertical, screenHeight * 0.01)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
}
