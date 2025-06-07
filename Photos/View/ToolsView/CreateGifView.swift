//
//  CreateGifView.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI
import PhotosUI
import AVKit
import AVFoundation
import MobileCoreServices
import Photos
import UniformTypeIdentifiers

struct CreateGifView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CreateGifViewModel()
    @State private var showExportPicker: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea()

            VStack(spacing: 24) {
                header
                Spacer()
                content
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 24)

            if viewModel.isProcessing {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.4)
                    Text("Generating GIF...")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .onAppear {
            viewModel.checkPhotoLibraryPermission()
        }
        .onChange(of: viewModel.selectedVideo) { newValue in
            if let item = newValue {
                viewModel.loadVideo(item: item)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: viewModel.currentView)
    }

    var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("🎞️ Create GIF")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Transform your video into animated magic")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Circle().fill(Color.white.opacity(0.2)))
            }
        }
        .padding(.top, 24)
    }

    @ViewBuilder
    var content: some View {
        switch viewModel.currentView {
        case .pickVideo:
            VStack(spacing: 28) {
                Image(systemName: "film.stack.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white.opacity(0.85))
                    .transition(.scale)

                Text("Select a video to convert")
                    .font(.title3.weight(.medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                PhotosPicker(selection: $viewModel.selectedVideo, matching: .videos) {
                    Label("Pick from Library", systemImage: "photo.on.rectangle")
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DarkFancyButtonStyle())
            }

        case .trimVideo:
            VStack(spacing: 20) {
                if let url = viewModel.videoURL {
                    ZStack(alignment: .center) {
                        VideoPlayer(player: AVPlayer(url: url))
                            .frame(height: 260)
                            .cornerRadius(16)
                            .shadow(radius: 8)
                        Image(systemName: "play.circle.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.6))
                            .transition(.opacity)
                    }

                    GradientSlider(label: "Start", value: $viewModel.startTime, range: 0...viewModel.endTime, step: 0.1)
                    GradientSlider(label: "End", value: $viewModel.endTime, range: viewModel.startTime...(viewModel.videoDuration(for: url) ?? 0), step: 0.1)

                    Button("Generate GIF") {
                        viewModel.trimAndConvertToGif()
                    }
                    .buttonStyle(DarkFancyButtonStyle())
                }
            }

        case .previewGif:
            VStack(spacing: 24) {
                if let gifURL = viewModel.gifURL,
                   let gifData = try? Data(contentsOf: gifURL) {
                    Image(uiImage: UIImage(contentsOfFile: gifURL.path) ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(height: 240)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .transition(.scale)

                    Text("Your GIF is ready 🎉")
                        .foregroundColor(.white)
                        .font(.title3.bold())

                    Button("Save to Files") {
                        showExportPicker = true
                    }
                    .buttonStyle(DarkFancyButtonStyle())
                    .sheet(isPresented: $showExportPicker) {
                        DocumentPicker(gifData: gifData, suggestedName: viewModel.generateGifFilename())
                    }
                }
            }
        }
    }
}

struct DarkFancyButtonStyle: ButtonStyle {
    var baseColor: Color = .purple

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        baseColor.opacity(configuration.isPressed ? 0.6 : 0.8),
                        Color.gray.opacity(configuration.isPressed ? 0.9 : 1.0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: baseColor.opacity(0.3), radius: 10, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct GradientSlider: View {
    var label: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double

    var body: some View {
        VStack(spacing: 8) {
            Text("\(label): \(String(format: "%.1f", value))s")
                .font(.headline)
                .foregroundColor(.white)

            Slider(value: $value, in: range, step: step)
                .accentColor(.purple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.bottom, 6)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
