//
//  ImageSelectorViewModel.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI

class ImageSelectorViewModel: ObservableObject {
    
    @Published var selectedImage: UIImage? = nil
    @Published var assets: [Asset] = []
    
    let imageSelectorService: ImagePickerForGifs
    
    init() {
        imageSelectorService = .init()
        bindServices()
    }
    
    func bindServices() {
        imageSelectorService.$fetchedPhotos
            .assign(to: &$assets)
    }
    
}

