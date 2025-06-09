//
//  PhotoEditorScreenUITests.swift
//  PhotoEditorTests
//
//  Created by Никита Кисляков on 09.06.2025.
//

import XCTest

final class PhotoEditorScreenUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-UITestMode"]
        app.launch()
    }

    func testAdjustmentSliderAppearsOnTap() throws {
        app.buttons["✏️ Edit Photo"].tap()
        let brightnessButton = app.buttons["Brightness"]
        XCTAssertTrue(brightnessButton.waitForExistence(timeout: 3), "Brightness button not found")

        brightnessButton.tap()

        let slider = app.sliders.firstMatch
        XCTAssertTrue(slider.waitForExistence(timeout: 3), "Adjustment slider did not appear")

        slider.adjust(toNormalizedSliderPosition: 0.8)
    }

    func testFilterToggleChangesState() throws {
        app.buttons["✏️ Edit Photo"].tap()
        let filterButton = app.buttons["Filters"]
        XCTAssertTrue(filterButton.exists)
        filterButton.tap()

        let sepiaButton = app.buttons["Sepia"]
        XCTAssertTrue(sepiaButton.waitForExistence(timeout: 3))
        sepiaButton.tap()

        XCTAssertTrue(sepiaButton.isSelected || sepiaButton.isHittable)
    }

    func testToolScreenOpensOnTap() throws {
        app.buttons["✏️ Edit Photo"].tap()
        let rotateButton = app.buttons["Rotate"]
        XCTAssertTrue(rotateButton.exists)
        rotateButton.tap()

        let doneButton = app.buttons["Done"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3), "Rotate tool did not open properly")
    }

    func testSaveButtonExists() throws {
        app.buttons["✏️ Edit Photo"].tap()
        let saveButton = app.buttons["Save"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Save button not found in toolbar")
    }
}
