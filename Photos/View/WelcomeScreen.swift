//
//  WelcomeScreen.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI

struct WelcomeScreen: View {
    @State private var showImagePicker = false
    @State private var navigateToCreateGif = false
    @State private var showCamera = false
    @State private var selectedImage: UIImage? = nil
    @State private var showPreviewScreen = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Text("Welcome to AddEditor")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                        Text("Let’s start by uploading your first image")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Button(action: {
                        showImagePicker = true
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .accessibilityIdentifier("Add_button")
                        }
                    }
                    
                    Text("Tap to add an image")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 16) {
                        Text("or choose an option")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 24) {
                            sourceButton(title: "Create GIF", icon: "photo.on.rectangle") {
                                navigateToCreateGif = true
                            }

                            NavigationLink(destination: CreateGifView(), isActive: $navigateToCreateGif) {
                                EmptyView()
                            }
                            .hidden()
                            
                            sourceButton(title: "Camera", icon: "camera") {
                                showCamera = true
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    
                    Spacer()
                    
                    Text("Your image will remain private and secure")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom)
                    
                }
                .padding()
                .navigationDestination(isPresented: $showPreviewScreen) {
                    if let image = selectedImage {
                        PhotoPreviewScreen(image: image)
                    }
                }
                
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            showPreviewScreen = true
                        }
                    }
            }
            .sheet(isPresented: $showCamera) {
                CameraPicker(selectedImage: $selectedImage)
                    .onDisappear {
                        if selectedImage != nil {
                            showPreviewScreen = true
                        }
                    }
            }
        }
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-UITestMode") {
                if let mockImage = UIImage(named: "placeholder") {
                    self.selectedImage = mockImage
                    self.showPreviewScreen = true
                }
            }
        }
    }

    private func sourceButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.purple)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
            .frame(width: 100, height: 80)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    WelcomeScreen()
}
