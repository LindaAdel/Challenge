//
//  ChallengeTests.swift
//  ChallengeTests
//
//  Created by Linda adel on 1/27/22.
//

import XCTest
@testable import Challenge

class ChallengeTests: XCTestCase {

    func testJSONMapping() throws {
            let bundle = Bundle(for: type(of: self))

            guard let url = bundle.url(forResource: "products", withExtension: "json") else {
                XCTFail("Missing file: products.json")
                return
            }

            let jsonData = try Data(contentsOf: url)
        let products: [ProductModel] = try JSONDecoder().decode([ProductModel].self, from: jsonData)
        let product = products[0]
            XCTAssertEqual(product.id, 1)
            XCTAssertEqual(product.price, 754)
        }

}
