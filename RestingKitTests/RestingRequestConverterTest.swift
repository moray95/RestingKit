//
//  RestingRequestConverterTest.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import XCTest
import RestingKit

class RestingRequestConverterTest: XCTestCase {
    let baseUrl = "http://localhost"

    func testCanConvertGet() {
        let requestConverter = RestingRequestConverter()
        let endpoint = Endpoint<Nothing, Nothing>(.get, "/", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())

        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))

        XCTAssertNil(httpRequest?.fileUrl)

        XCTAssertEqual(httpRequest?.urlRequest.httpMethod, "GET")
        XCTAssertNil(httpRequest?.urlRequest.httpBody)
        XCTAssertEqual(httpRequest?.urlRequest.url?.absoluteString, "\(baseUrl)/")
    }

    func testCanConvertPost() {
        let requestConverter = RestingRequestConverter()
        let endpoint = Endpoint<Nothing, Nothing>(.post, "/", encoding: .json)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())

        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))

        XCTAssertNil(httpRequest?.fileUrl)

        XCTAssertEqual(httpRequest?.urlRequest.httpMethod, "POST")
        XCTAssertEqual(httpRequest?.urlRequest.url?.absoluteString, "\(baseUrl)/")
        XCTAssertEqual(httpRequest?.urlRequest.allHTTPHeaderFields?["Content-Type"], "application/json")

        // Try to parse the body
        XCTAssertNotNil(httpRequest?.urlRequest.httpBody)
        guard let body = httpRequest?.urlRequest.httpBody else {
            return
        }
        XCTAssertNoThrow(try JSONDecoder().decode([String: String].self, from: body))
    }

    func testCanAddheaders() {
        let requestConverter = RestingRequestConverter()
        let endpoint = Endpoint<Nothing, Nothing>(.get, "/", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing(), headers: ["my-customer-header": "42"])

        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))
        XCTAssertEqual(httpRequest?.urlRequest.allHTTPHeaderFields?["my-customer-header"], "42")
    }

    func testCanSubstitutePathVariables() {
        let requestConverter = RestingRequestConverter()
        let endpoint = Endpoint<Nothing, Nothing>(.get, "/{{id}}", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing(), pathVariables: ["id": 42])
        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))

        XCTAssertEqual(httpRequest?.urlRequest.url?.absoluteString, "\(baseUrl)/42")
    }

    func testCanSubstituteAlwaysOnPathVariables() {
        let config = RestingRequestConverter.Configuration(pathVariableProvider: RestingPathVariableProvider(providers: ["id": { 42 }]))
        let requestConverter = RestingRequestConverter(configuration: config)
        let endpoint = Endpoint<Nothing, Nothing>(.get, "/{{id}}", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())
        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))

        XCTAssertEqual(httpRequest?.urlRequest.url?.absoluteString, "\(baseUrl)/42")
    }

    func testValueFromRequestOverridesAlwaysOnPathVariable() {
        let config = RestingRequestConverter.Configuration(pathVariableProvider: RestingPathVariableProvider(providers: ["id": { 41 }]))
        let requestConverter = RestingRequestConverter(configuration: config)
        let endpoint = Endpoint<Nothing, Nothing>(.get, "/{{id}}", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing(), pathVariables: ["id": 42])
        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))

        XCTAssertEqual(httpRequest?.urlRequest.url?.absoluteString, "\(baseUrl)/42")
    }

    func testIncludesAlwaysOnHeaders() {
        let config = RestingRequestConverter.Configuration(headerProvider: RestingHeaderProvider(providers: ["my-customer-header": { "42" }]))
        let requestConverter = RestingRequestConverter(configuration: config)
        let endpoint = Endpoint<Nothing, Nothing>(.get, "/", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())
        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))

        XCTAssertEqual(httpRequest?.urlRequest.allHTTPHeaderFields?["my-customer-header"], "42")
    }

    func testValueFromRequestOverridesAlwaysOnheader() {
        let config = RestingRequestConverter.Configuration(headerProvider: RestingHeaderProvider(providers: ["my-customer-header": { "41" }]))
        let requestConverter = RestingRequestConverter(configuration: config)
        let endpoint = Endpoint<Nothing, Nothing>(.get, "/", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing(), headers: ["my-customer-header": "42"])
        let httpRequest = XCTAssertNoThrow(try requestConverter.toHTTPRequest(request, baseUrl: baseUrl, forUpload: false))

        XCTAssertEqual(httpRequest?.urlRequest.allHTTPHeaderFields?["my-customer-header"], "42")
    }
}
