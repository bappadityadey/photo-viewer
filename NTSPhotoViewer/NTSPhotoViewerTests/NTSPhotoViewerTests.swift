//
//  NTSPhotoViewerTests.swift
//  NTSPhotoViewerTests
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import XCTest
@testable import NTSPhotoViewer

class NTSPhotoViewerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testPhotosListData() {
        guard let url = URL(string: APIRequests.photoListUrl) else { return }
        let promise = expectation(description: "Photo List Request")
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do {
                let result = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                print(result)
                //XCTAssertTrue((result as? Array<Dictionary>) != nil)
                promise.fulfill()
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
        waitForExpectations(timeout: 10, handler: nil)
    }
}
