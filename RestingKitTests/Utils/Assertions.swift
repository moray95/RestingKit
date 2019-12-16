//
//  Assertions.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import Foundation
import XCTest
import PromiseKit

func XCTAssertEqual(
    _ expected: [(String, String)],
    _ actual: [URLQueryItem],
    message: @autoclosure () -> String = "",
    file: StaticString = #file,
    line: UInt = #line
) {
    let mappedExpected = expected.sorted { $0.0 < $1.0 }.map(URLQueryItem.init)
    let sortedActual = actual.sorted { $0.name < $1.name }
    XCTAssertEqual(mappedExpected, sortedActual, message(), file: file, line: line)
}

@discardableResult
func XCTAssertNoThrow<T>(
    _ block: @autoclosure () throws -> T,
    file: StaticString = #file,
    line: UInt = #line
) -> T? {
    do {
        return try block()
    } catch {
        XCTFail("Threw exception \(error)", file: file, line: line)
        return nil
    }
}

extension Promise {
    @discardableResult
    func assertSuccess(
        file: StaticString = #file,
        line: UInt = #line
    ) -> PMKFinalizer {
        self.catch {
            XCTFail("Promise failed with error \($0)", file: file, line: line)
        }
    }
}


extension PMKFinalizer {
    func waitForTesting(in testCase: XCTestCase, description: String = "", timeout: TimeInterval = 0.1) {
        let expectation = XCTestExpectation(description: description)
        finally(expectation.fulfill)
        testCase.wait(for: [expectation], timeout: timeout)
    }
}
