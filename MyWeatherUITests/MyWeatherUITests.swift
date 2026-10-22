//
//  MyWeatherUITests.swift
//  MyWeatherUITests
//
//  Created by Rock on 14/9/2024.
//

import XCTest

final class MyWeatherUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    /// The capture script installs public JSON responses before this test runs.
    @MainActor
    func testRecordedDemo() throws {
        let app = XCUIApplication()
        app.launchArguments = ["--recorded-demo"]
        app.launch()
        XCTAssertTrue(app.staticTexts["demo-attribution"].waitForExistence(timeout: 15))
        let card = app.staticTexts["Weather now"]
        XCTAssertTrue(card.exists)
        Thread.sleep(forTimeInterval: 3)
        let start = card.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        start.press(forDuration: 0.2, thenDragTo: start.withOffset(CGVector(dx: 0, dy: -350)))
        XCTAssertTrue(app.staticTexts["For More Info"].waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 4)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Recorded weather details"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        let raised = card.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        raised.press(forDuration: 0.2, thenDragTo: raised.withOffset(CGVector(dx: 0, dy: 350)))
        Thread.sleep(forTimeInterval: 3)
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
