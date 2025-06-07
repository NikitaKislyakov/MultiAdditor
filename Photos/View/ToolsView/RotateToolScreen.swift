//
//  RotateToolScreen.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 06.06.2025.
//

import SwiftUI

struct RotateToolScreen: View {
    @ObservedObject var viewModel: PhotoEditorViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Preview image
                    Image(uiImage: viewModel.processedImage ?? viewModel.originalImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: UIScreen.main.bounds.height * 0.5)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()

                    // Rotation slider
                    VStack(spacing: 8) {
                        Text("Rotation: \(Int(viewModel.rotationAngle * 180 / .pi))°")
                            .font(.headline)
                            .foregroundColor(.white)

                        Slider(value: Binding(
                            get: { viewModel.rotationAngle },
                            set: {
                                viewModel.rotationAngle = $0
                                viewModel.applyProcessing()
                            }
                        ), in: -Double.pi...Double.pi)
                            .accentColor(.purple)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)
                    .padding(.bottom, 12)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("Rotate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                }
            }
        }
    }
}
