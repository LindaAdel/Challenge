//
//  ChallengeUITests.swift
//  ChallengeUITests
//
//  Created by Linda adel on 1/27/22.
//

import XCTest
@testable import Challenge


class ChallengeUITests: XCTestCase {
    let app = XCUIApplication()
   
    
    override func setUpWithError() throws {
       continueAfterFailure = false
           app.launch()
       
    }
    
    func testNavigation() {
        let collectionViewCell = app.collectionViews.cells.staticTexts["754$"]
        XCTAssertTrue(collectionViewCell.exists)
       
    }
    func testDetailView(){
       
    }


    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
       
    }

   
}
