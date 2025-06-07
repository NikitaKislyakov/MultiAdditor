//
//  CollageMainView.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI

struct CollageMainView: View {
    
    @StateObject var collageSelector: CollageSelectorViewModel = .init()
    @StateObject var imagesSelector: ImageSelectorViewModel = .init()
    @Environment(\.dismiss) var dismiss
    
    @State var selectedRatio: CollageRatios = .oneone
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.black]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 12) {
                    Text("Choose layout styles and add images depending on the icons amout")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    GeometryReader { proxy in
                        VStack(alignment: .center) {
                            Spacer()
                            if let collage = collageSelector.selectedCollage {
                                CollageView(
                                    size: proxy.size.minusHeight(100 + 100).sizeWith(ratio: selectedRatio),
                                    type: collageSelector.selectedCollage!
                                )
                                .id(collage.id)
                                .environmentObject(collageSelector)
                                .cornerRadius(12)
                                .transition(.opacity)
                            }
                            Spacer()
                            if collageSelector.showCollageOptions != .home {
                                Rectangle()
                                    .fill(.clear)
                                    .frame(height: 100 + 100)
                                    .transition(.move(edge: .bottom))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .toolbar(content: {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button {
                                    saveCurrentCollage()
                                } label: {
                                    Image(uiImage: UIImage(systemName: "square.and.arrow.down")!)
                                        .foregroundStyle(.black)
                                }
                            }
                            ToolbarItem(placement: .topBarLeading) {
                                Button {
                                    dismiss.callAsFunction()
                                } label: {
                                    Text("Exit")
                                        .foregroundStyle(.black)
                                }
                            }
                        })
                        .navigationTitle("Add your photos")
                        .navigationBarTitleDisplayMode(.large)
                    }
                    .padding()
                    .padding()
                    .overlay(alignment: .bottom) {
                        if collageSelector.showCollageOptions == .collages {
                            VStack {
                                CollageRatioPicker(selected: $selectedRatio)
                                CollageListView()
                                    .environmentObject(collageSelector)
                            }
                            .frame(height: 100 + 100)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            
                        } else if collageSelector.showCollageOptions == .images {
                            ImagesSelector()
                                .environmentObject(imagesSelector)
                                .environmentObject(collageSelector)
                                .frame(height: 100)
                                .frame(maxWidth: .infinity)
                                .padding(.bottom)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            HStack(spacing: 24) {
                                Spacer()
                                layoutsBtn
                                Spacer()
                            }
                            .padding(.vertical)
                        }
                    }
                    .animation(.easeInOut(duration: 0.35), value: collageSelector.showCollageOptions)
                    .animation(.easeInOut(duration: 0.3), value: collageSelector.selectedCollage)
                }
            }
        }
    }
}

extension CollageMainView {
    
    var layoutsBtn: some View {
        Button {
            collageSelector.changeView(to: .collages)
        } label: {
            Image(uiImage: UIImage(systemName: "rectangle.3.offgrid.fill")!)
                .resizable()
                .tint(.white.opacity(3/4))
                .frame(width: 42, height: 42)
        }
        .buttonStyle(DarkFancyButtonStyle())
    }
    
    func saveCurrentCollage() {
        guard let collage = collageSelector.selectedCollage else { return }
        
        let collageImage = CollageView(
            size: CGSize(width: 1000, height: 1000), // Высокое качество
            type: collage
        )
            .environmentObject(collageSelector)
            .snapshot(size: CGSize(width: 1000, height: 1000))
        
        UIImageWriteToSavedPhotosAlbum(collageImage, nil, nil, nil)
    }
    
}

struct CollageMainView_Previews: PreviewProvider {
    static var previews: some View {
        CollageMainView()
    }
}
