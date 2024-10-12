import XCTest
@testable import MovieQuiz

final class MovieQuizUITests: XCTestCase {

    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    // MARK: - Buttons tests
    
    func testYesButton() {
        
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(firstPosterData == secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(firstPosterData == secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    // MARK: - Alert test

    func testResultsAlert() {
        
        sleep(3)
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let resultsAlert = app.alerts.firstMatch
        let alertHeadText = resultsAlert.label
        let alertButtonText = resultsAlert.buttons.firstMatch.label
        
        XCTAssertTrue(resultsAlert.exists)
        XCTAssertTrue(alertHeadText == "Этот раунд окончен!")
        XCTAssertTrue(alertButtonText == "Сыграть еще раз")
    }
    
    func testResultsAlertDismiss() {
        
        sleep(3)
        
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let resultsAlert = app.alerts.firstMatch
        resultsAlert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(resultsAlert.exists)
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
