//
//  PokeCoachTests.swift
//  PokeCoachTests
//
//  Created by Jong Ho Lee on 11/7/22.
//

import XCTest
@testable import PokeCoach

final class PokeCoachTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        ActivityDataManager.shared.wipeAllData()
    }

    func testDummyDataFill() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        ActivityDataManager.shared.fillWithDummyData()
        
        XCTAssertEqual(ActivityDataManager.shared.heartrateData.count, 5)
    }
    
    func testDummyDataWipe() throws {
        XCTAssertEqual(ActivityDataManager.shared.heartrateData.count, 0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
