//
//  ProductServiceTest.swift
//  ChallengeTests
//
//  Created by Linda adel on 2/1/22.
//

import XCTest
@testable import Challenge

class ProductServiceTest: XCTestCase {

    var session : URLSession!

    override func setUpWithError() throws {
        try super.setUpWithError()
        session = URLSession(configuration: .default)
    }

    override func tearDownWithError() throws {
        session = nil
          try super.tearDownWithError()
    }

    func testValidApiCallGetsHTTPStatusCode200() throws {
      
      let urlString = "https://api.jsonserve.com/mIqgTj"
      let url = URL(string: urlString)!
      let promise = expectation(description: "Status code: 200")

      let dataTask = session.dataTask(with: url) { _, response, error in
        if let error = error {
          XCTFail("Error: \(error.localizedDescription)")
          return
        } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
          if statusCode == 200 {
            promise.fulfill()
          } else {
            XCTFail("Status code: \(statusCode)")
          }
        }
      }
      dataTask.resume()
      wait(for: [promise], timeout: 5)
       
    }
 
}
