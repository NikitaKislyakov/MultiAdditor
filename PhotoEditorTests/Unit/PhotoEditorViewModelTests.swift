//
//  PhotoEditorViewModelTests.swift
//  PhotoEditorTests
//
//  Created by Никита Кисляков on 09.06.2025.
//

import XCTest
import SwiftUI

@testable import PhotoEditor

final class PhotoEditorViewModelTests: XCTestCase {
    
    // MARK: - Вспомогательный метод
    
    private func makeTestImage(color: UIColor = .red, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    // MARK: - Тесты

    func testInitialization() {
        let image = makeTestImage()
        let viewModel = PhotoEditorViewModel(image: image)
        
        XCTAssertEqual(viewModel.originalImage.pngData(), image.pngData())
        XCTAssertNotNil(viewModel.processedImage)
        XCTAssertEqual(viewModel.brightness, 0.0)
        XCTAssertEqual(viewModel.contrast, 1.0)
    }

    func testBrightnessAdjustment() {
        let viewModel = PhotoEditorViewModel(image: makeTestImage())
        
        viewModel.setValueForAdjustment(.brightness, newValue: 0.8)
        
        XCTAssertEqual(viewModel.brightness, 0.8)
        XCTAssertNotNil(viewModel.processedImage)
    }

    func testAddingAndRemovingColorFilter() {
        let viewModel = PhotoEditorViewModel(image: makeTestImage())
        
        viewModel.addColorFilter(.sepia)
        XCTAssertTrue(viewModel.colorFilters.contains(.sepia))
        
        viewModel.removeColorFilter(.sepia)
        XCTAssertFalse(viewModel.colorFilters.contains(.sepia))
    }

    func testValueForAdjustmentReturnsCorrectValue() {
        let viewModel = PhotoEditorViewModel(image: makeTestImage())
        
        viewModel.sharpness = 1.5
        let value = viewModel.valueForAdjustment(.sharpness)
        
        XCTAssertEqual(value, 1.5)
    }

    func testUpdateToNewImage() {
        let initial = makeTestImage(color: .blue)
        let updated = makeTestImage(color: .green)

        let viewModel = PhotoEditorViewModel(image: initial)
        viewModel.setValueForAdjustment(.contrast, newValue: 1.8)
        
        viewModel.update(to: updated)
        
        XCTAssertEqual(viewModel.originalImage.pngData(), updated.pngData())
        XCTAssertNotNil(viewModel.processedImage)
    }
}
