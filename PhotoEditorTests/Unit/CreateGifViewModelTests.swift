//
//  CreateGifViewModelTests.swift
//  PhotoEditorTests
//
//  Created by Никита Кисляков on 09.06.2025.
//

import XCTest
@testable import PhotoEditor

final class CreateGifViewModelTests: XCTestCase {

    func testVideoDurationCalculation() {
        // Arrange
        let viewModel = CreateGifViewModel()
        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.url(forResource: "testVideo", withExtension: "mp4") else {
            XCTFail("Test video not found")
            return
        }

        // Act
        let duration = viewModel.videoDuration(for: url)

        // Assert
        XCTAssertNotNil(duration)
        XCTAssertTrue(duration! > 0, "Duration should be greater than zero")
    }

    func testGenerateGifFilenameFormat() {
        let viewModel = CreateGifViewModel()
        let filename = viewModel.generateGifFilename()

        let pattern = #"gif_\d{8}_\d{6}\.gif"#
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: filename.utf16.count)
        XCTAssertNotNil(regex.firstMatch(in: filename, options: [], range: range))
    }

    func testGifGenerationSetsCorrectState() {
        // Arrange
        let viewModel = CreateGifViewModel()

        let testBundle = Bundle(for: type(of: self))
        guard let url = testBundle.url(forResource: "testVideo", withExtension: "mp4") else {
            XCTFail("Test video not found")
            return
        }

        viewModel.videoURL = url
        viewModel.startTime = 0
        viewModel.endTime = 2

        let expectation = XCTestExpectation(description: "GIF generation completed")
        
        // Act
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            XCTAssertFalse(viewModel.isProcessing)
            XCTAssertNotNil(viewModel.gifURL)
            XCTAssertEqual(viewModel.currentView, .previewGif)
            expectation.fulfill()
        }

        viewModel.trimAndConvertToGif()
        // Assert
        wait(for: [expectation], timeout: 10)
    }
}
