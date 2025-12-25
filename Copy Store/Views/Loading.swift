//
//  Loading.swift
//  Copy Store
//
//  Created by Алкександр Степанов on 23.12.2025.
//

import SwiftUI

struct Loading: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .ignoresSafeArea()
            
            // Placeholder - будет добавлено позже
            Text("Loading...")
                .font(.custom("SF Pro Display", size: 24))
                .foregroundColor(Color("text_1Color"))
        }
    }
}

#Preview {
    Loading()
}
