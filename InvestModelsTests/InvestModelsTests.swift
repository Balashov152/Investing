//
//  InvestModelsTests.swift
//  InvestModelsTests
//
//  Created by Sergey Balashov on 21.12.2020.
//

import XCTest
@testable import InvestModels

class InvestModelsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    lazy var sorted: [Int] = {
        var array: [Int] = []
        for i in 0...1_000_000 {
            array.append(i)
        }
        return array
    }()
    
    lazy var nonsorted: [Int] = {
        var array: [Int] = []
        for i in 0...1_000_000 {
            array.append(Int.random(in: 0...1_000_000))
        }
        return array
    }()

    func testPerformanceExample() throws {
        let sorted = nonsorted
        self.measure {
            let sort = sorted.sorted()
        }
    }

}
