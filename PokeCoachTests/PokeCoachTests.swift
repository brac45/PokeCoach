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
    }
    
    func testFileRead() throws {
        if let path = Bundle.main.path(forResource: "sample_run_1", ofType: "gpx") {
            print(path)
        } else {
            print("Not found")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
