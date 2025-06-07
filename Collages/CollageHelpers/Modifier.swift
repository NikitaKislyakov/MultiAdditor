//
//  Modifier.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI
import UIKit

struct BgModifier: ViewModifier {
    
    var color: Color
    var fill: Bool = false
    
    func body(content: Content) -> some View {
        if fill {
            content
                .background {
                    Rectangle().fill(color)
                }
        } else {
            content
                .background {
                    Rectangle().stroke().fill(color)
                }
        }
    }
    
}

extension View {
    func snapshot(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.frame = CGRect(origin: .zero, size: size)

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
