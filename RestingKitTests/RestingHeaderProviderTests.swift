//
//  RestingHeaderProviderTests.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 20.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import XCTest
import RestingKit

class RestingHeaderProviderTests: XCTestCase {
    var provider: RestingHeaderProvider!

    override func setUp() {
        super.setUp()
        provider = RestingHeaderProvider()
    }

    override func tearDown() {
        super.tearDown()
        provider = nil
    }

    func testCanAddStaticHeader() {
        provider.addHeader(key: "key", value: "value")
        XCTAssertEqual(["key": "value"], provider.headers)
    }

    func testRemovesNilHeaders() {
        provider.addHeader(key: "key") { nil }
        XCTAssertEqual([:], provider.headers)
    }

    func testCanRemoveHeader() {
        provider.addHeader(key: "key", value: "")
        provider.removeHeader(for: "key")
        XCTAssertEqual([:], provider.headers)
    }
}
