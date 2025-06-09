//
//  PhotoEditorScreen.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI
import SwiftyCrop

struct PhotoEditorScreen: View {
    @StateObject private var viewModel: PhotoEditorViewModel
    
    @State private var openColorFilters = false
    @State private var activeToolScreen: EditorTool? = nil
    @State private var showToolScreen = false
    
    // Example list of available color filters
    private let availableColorFilters: [ColorFilterItem] = [
        ColorFilterItem(filter: .sepia, name: "Sepia", icon: "Sepia"),
        ColorFilterItem(filter: .grayscale, name: "Grayscale", icon: "Grayscale"),
        ColorFilterItem(filter: .colorInvert, name: "Invert", icon: "Invert"),
        ColorFilterItem(filter: .colorMonochrome(color: .gray), name: "Mono", icon: "Monochrome"),
        ColorFilterItem(filter: .colorPosterize(levels: 6), name: "Posterize", icon: "Posterize")
    ]

    init(image: UIImage) {
        _viewModel = StateObject(wrappedValue: PhotoEditorViewModel(image: image))
    }

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                imageView

                Spacer()

                if let currentAdjustment = viewModel.selectedAdjustment {
                    sliderView(currentAdjustment: currentAdjustment)
                }

                VStack(spacing: 12) {
                    optionsScrollView

                    if openColorFilters {
                        filtersScrollView
                    }

                    toolScrollView
                }
                .background(Color.gray.opacity(0.3).ignoresSafeArea(edges: .bottom))
            }
            .padding(.top, 8)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    saveImageToPhotos()
                }
            }
        }
        .fullScreenCover(isPresented: $showToolScreen) {
            if let activeTool = activeToolScreen {
                toolScreen(for: activeTool)
            }
        }
        .navigationTitle("Edit Photo")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: Subviews
    
    // MARK: Image
    private var imageView: some View {
        Image(uiImage: viewModel.processedImage ?? viewModel.originalImage)
            .resizable()
            .scaledToFit()
            .frame(maxHeight: UIScreen.main.bounds.height * 0.55)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal)
            .padding(.top, 12)
    }
    
    // MARK: Options
    private var optionsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(AdjustmentOption.allCases, id: \.self) { option in
                    Button(action: {
                        withAnimation(.easeInOut) {
                            if option == viewModel.selectedAdjustment {
                                viewModel.selectedAdjustment = nil
                            } else {
                                viewModel.selectedAdjustment = option
                            }
                        }
                    }) {
                        Text(option.rawValue.capitalized)
                            .font(.footnote.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(viewModel.selectedAdjustment == option ? Color.purple : Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
    }
    
    // MARK: Tools
    private var toolScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(EditorTool.allCases, id: \.self) { tool in
                    Button(action: {
                        if tool == .filters {
                            showToolScreen = false
                            withAnimation(.bouncy) {
                                openColorFilters.toggle()
                            }
                        } else {
                            activeToolScreen = tool
                            showToolScreen = true
                            viewModel.selectedTool = tool
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(tool.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .padding(10)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())

                            Text(tool.rawValue.capitalized)
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
    
    // MARK: Filters
    private var filtersScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(availableColorFilters, id: \.self) { item in
                    Button(action: {
                        if viewModel.colorFilters.contains(item.filter) {
                            viewModel.removeColorFilter(item.filter)
                        } else {
                            viewModel.addColorFilter(item.filter)
                        }
                    }) {
                        VStack(spacing: 6) {
                            Image(item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                                .padding(10)
                                .background(viewModel.colorFilters.contains(item.filter) ? Color.purple : Color.white.opacity(0.1))
                                .clipShape(Circle())

                            Text(item.name)
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .transition(.move(edge: .leading))
    }
    
    // MARK: Slider
    private func sliderView(currentAdjustment: AdjustmentOption) -> some View {
        VStack(spacing: 8) {
            Text(currentAdjustment.rawValue.capitalized)
                .font(.headline)
                .foregroundColor(.white)

            Slider(value: Binding(
                get: { viewModel.valueForAdjustment(currentAdjustment) },
                set: { viewModel.setValueForAdjustment(currentAdjustment, newValue: $0) }
            ), in: currentAdjustment.range)
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
    
    // MARK: Private functions
    
    private func filterName(for filter: ColorFilter) -> String {
        switch filter {
        case .sepia: return "Sepia"
        case .grayscale: return "Grayscale"
        case .colorInvert: return "Invert"
        case .colorMonochrome: return "Mono"
        case .colorPosterize: return "Posterize"
        }
    }

    private func filterIcon(for filter: ColorFilter) -> String {
        // Просто простые иконки (можно заменить на кастомные)
        switch filter {
        case .sepia: return "paintbrush"
        case .grayscale: return "circle.lefthalf.fill"
        case .colorInvert: return "arrow.uturn.left"
        case .colorMonochrome: return "drop.fill"
        case .colorPosterize: return "slider.horizontal.3"
        }
    }
    
    @ViewBuilder
    @discardableResult
    private func toolScreen(for tool: EditorTool) -> some View {
        switch tool {
        case .filters:
            filtersScrollView
        case .rotate:
            RotateToolScreen(viewModel: viewModel)
        case .crop:
            SwiftyCropView(imageToCrop: viewModel.processedImage ?? UIImage(), maskShape: .rectangle) { image in
                viewModel.update(to: image ?? UIImage())
            }
        case .collage:
            CollageScreen()
        }
    }
    
    private func saveImageToPhotos() {
        guard let imageToSave = viewModel.processedImage else { return }

        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
    }
}

struct ColorFilterItem: Hashable {
    let filter: ColorFilter
    let name: String
    let icon: String
}

#Preview {
    PhotoEditorScreen(image: UIImage(named: "placeholder") ?? UIImage())
}
