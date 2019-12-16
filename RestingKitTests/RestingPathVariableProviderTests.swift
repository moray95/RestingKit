//
//  RestingPathVariableProviderTests.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 20.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import XCTest
import RestingKit

class RestingPathVariableProviderTests: XCTestCase {
    var provider: RestingPathVariableProvider!

    override func setUp() {
        super.setUp()
        provider = RestingPathVariableProvider()
    }

    override func tearDown() {
        super.tearDown()
        provider = nil
    }

    func testCanAddStaticVariable() {
        provider.addVariable(key: "test", value: 1)
        XCTAssertEqual(1, provider.variables.count)
        XCTAssertEqual(1, provider.variables["test"] as? Int)
    }

    func testRemovesNilVariables() {
        provider.addVariable(key: "test") { nil }
        XCTAssertEqual([], Array(provider.variables.keys))
    }

    func testCanRemoveVariable() {
        provider.addVariable(key: "test", value: 1)
        provider.removeVariable(for: "test")
        XCTAssertEqual([], Array(provider.variables.keys))
    }
}
