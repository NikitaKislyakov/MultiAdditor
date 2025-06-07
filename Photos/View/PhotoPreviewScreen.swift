//
//  PhotoPreviewScreen.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI

struct PhotoPreviewScreen: View {
    @State private var goToEditor = false
    
    let image: UIImage
    var onEdit: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: UIScreen.main.bounds.height * 0.55)
                    .cornerRadius(24)
                    .shadow(radius: 12)
                    .padding(.horizontal)

                Divider()
                    .background(Color.white.opacity(0.3))
                    .padding(.horizontal)

                Button(action: {
                    goToEditor = true
                }) {
                    Text("✏️ Edit Photo")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(colors: [Color.purple, Color.pink], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                NavigationLink(
                    destination: PhotoEditorScreen(image: image),
                    isActive: $goToEditor
                ) {
                    EmptyView()
                }
                .hidden()

                Text("You can crop, enhance, or animate this image")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    PhotoPreviewScreen(image: UIImage(named: "placeholder")!) {
        print("Edit tapped")
    }
}
