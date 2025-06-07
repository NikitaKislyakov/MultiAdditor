//
//  CollageScreen.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI

struct CollageScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea()
            NavigationStack {
                CollageMainView()
            }
        }
    }
}

struct CollageScreen_Previews: PreviewProvider {
    static var previews: some View {
        CollageScreen()
    }
}
