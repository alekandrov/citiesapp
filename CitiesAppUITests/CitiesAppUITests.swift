import XCTest

final class CitiesAppUITests: XCTestCase {

    private func searchField(in app: XCUIApplication) -> XCUIElement {
        let field = app.textFields["searchField"]
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Search field should exist on launch")
        return field
    }
    
    @MainActor
    func testSearchSydneyAppears() {
        let app = XCUIApplication()
        app.launch()
        
        let search = searchField(in: app)
        search.tap()
        search.typeText("Huab")
        
        XCTAssertTrue(app.staticTexts["Huabeitun, CN"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testIncrementalFiltering() {
        let app = XCUIApplication()
        app.launch()
        
        let search = searchField(in: app)
        search.tap()

        search.typeText("Alabas")
        XCTAssertTrue(app.staticTexts["Alabash Konrat, UA"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Alabaster, US"].waitForExistence(timeout: 2))

        search.typeText("t")
        XCTAssertFalse(app.staticTexts["Alabash Konrat, UA"].exists)
        XCTAssertTrue(app.staticTexts["Alabaster, US"].exists)

        search.typeText("a")
        sleep(1)
        XCTAssertFalse(app.staticTexts["Alabaster, US"].exists)
    }

    @MainActor
    func testOpenInfoFromCard() {
        let app = XCUIApplication()
        app.launch()
        
        let search = searchField(in: app)
        search.tap()
        search.typeText("Alabast")

        let infoButton = app.buttons["infoButton_4829762"].firstMatch
        if infoButton.exists {
            infoButton.tap()
        }

        XCTAssertTrue(app.navigationBars["Alabaster"].waitForExistence(timeout: 3))
    }
    
    @MainActor
    func testCellTapGesture() {
        let app = XCUIApplication()
        app.launch()
        
        let search = searchField(in: app)
        search.tap()
        search.typeText("Alabast")

        let cell = app.descendants(matching: .any)["cell_4829762"]
        XCTAssertTrue(cell.waitForExistence(timeout: 6), "The cell should exist")
        
        cell.tap()

        XCTAssertTrue(app.navigationBars["Alabaster"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.otherElements["cityMap"].waitForExistence(timeout: 3))
    }
}
