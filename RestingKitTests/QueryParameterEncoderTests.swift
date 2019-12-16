//
//  QueryParameterEncoderTest.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import XCTest
import RestingKit

class QueryParameterEncoderTests: XCTestCase {
    func testCanEncodeSimpleValues() {
        let encoder = QueryParameterEncoder()
        let simpleModel = SimpleModel(stringValue: "test", integer: 42)
        guard let encoded = XCTAssertNoThrow(try encoder.encode(simpleModel)) else { return }
        let expected = [
            ("stringValue", simpleModel.stringValue),
            ("integer", "\(simpleModel.integer)"),
        ]
        XCTAssertEqual(expected, encoded)
    }

    func testCanEncodeNestedObject() {
        let encoder = QueryParameterEncoder()
        let simpleModel = SimpleModel(stringValue: "test", integer: 42)
        let nestedModel = NestedModel(nested: simpleModel)
        guard let encoded = XCTAssertNoThrow(try encoder.encode(nestedModel)) else { return }
        let expected = [
            ("nested[stringValue]", simpleModel.stringValue),
            ("nested[integer]", "\(simpleModel.integer)")
        ]
        XCTAssertEqual(expected, encoded)
    }

    func testCanEncodeArrayWithSimpleValues() {
        let encoder = QueryParameterEncoder()
        let array = [1, 2, 3]
        let arrayModel = ArrayModel(array: array)
        guard let encoded = XCTAssertNoThrow(try encoder.encode(arrayModel)) else { return }
        let expected = array.map { ("array[]", "\($0)") }
        XCTAssertEqual(expected, encoded)
    }

    func testCanEncodeNestedArrayWithObjects() {
        let encoder = QueryParameterEncoder()
        let simpleModel = SimpleModel(stringValue: "test", integer: 42)
        let simpleModel2 = SimpleModel(stringValue: "test2", integer: 43)
        let nestedModel = ArrayModel(array: [simpleModel, simpleModel2])
        guard let encoded = XCTAssertNoThrow(try encoder.encode(nestedModel)) else { return }
        let expected = [
            ("array[][stringValue]", simpleModel.stringValue),
            ("array[][integer]", "\(simpleModel.integer)"),

            ("array[][stringValue]", simpleModel2.stringValue),
            ("array[][integer]", "\(simpleModel2.integer)")
        ]
        XCTAssertEqual(expected, encoded)
    }

    func testSnakeCaseKeyEncodingStrategy() {
        let encoder = QueryParameterEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let simpleModel = SimpleModel(stringValue: "test", integer: 42)
        guard let encoded = XCTAssertNoThrow(try encoder.encode(simpleModel)) else { return }
        let expected = [
            ("string_value", simpleModel.stringValue),
            ("integer", "\(simpleModel.integer)"),
        ]
        XCTAssertEqual(expected, encoded)
    }
}
