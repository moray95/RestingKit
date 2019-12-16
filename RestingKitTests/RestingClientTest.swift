//
//  RestingClientTest.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import XCTest
import RestingKit

class RestingClientTests: XCTestCase {

    func testCanSendRequestAndRecieveResponse() {
        let restingClient = RestingClient(baseUrl: "http://localhost",
                                          httpClient: EchoHttpClient(),
                                          requestConverter: RestingRequestConverter())

        let expectation = XCTestExpectation(description: "Send request")

        let body = SimpleModel(stringValue: "string", integer: 42)
        let endpoint = Endpoint<SimpleModel, SimpleModel>(.post, "/", encoding: .json)
        let request = RestingRequest(endpoint: endpoint, body: body)

        restingClient
            .perform(request)
            .done {
                XCTAssertEqual(body, $0.body)
            }
            .assertSuccess()
            .finally(expectation.fulfill)

        wait(for: [expectation], timeout: 0.1)
    }

    func testClientCallsInterceptor() {
        let interceptor = MockInterceptor()
        let restingClient = RestingClient(baseUrl: "http://localhost",
                                          httpClient: EchoHttpClient(),
                                          requestConverter: RestingRequestConverter(),
                                          interceptors: [interceptor])

        let expectation = XCTestExpectation(description: "Send request")

        let endpoint = Endpoint<Nothing, Nothing>(.get, "/", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())

        restingClient
            .perform(request)
            .asVoid()
            .done {
                XCTAssertTrue(interceptor.calledOnRequest)
                XCTAssertTrue(interceptor.calledOnResponse)
            }
            .assertSuccess()
            .finally(expectation.fulfill)

        wait(for: [expectation], timeout: 0.1)
    }

    func testCanHandleHttpErrors() {
        let restingClient = RestingClient(baseUrl: "http://localhost",
                                          httpClient: EchoHttpClient(status: 500),
                                          requestConverter: RestingRequestConverter())

        let expectation = XCTestExpectation(description: "Send request")

        let body = SimpleModel(stringValue: "string", integer: 42)
        let endpoint = Endpoint<SimpleModel, SimpleModel>(.post, "/", encoding: .json)
        let request = RestingRequest(endpoint: endpoint, body: body)

        restingClient
            .perform(request)
            .asVoid()
            .done { XCTFail("Expected promise to fail, bu succeeded") }
            .catch {
                guard let error = $0 as? HTTPError else {
                    XCTFail("Expected promise fail with HTTPError, found \($0) instead")
                    return
                }
                XCTAssertEqual(error.status, 500)
            }
            .finally(expectation.fulfill)

        wait(for: [expectation], timeout: 0.1)
    }

    func testCanHandleNoContent() {
        let restingClient = RestingClient(baseUrl: "http://localhost",
                                          httpClient: NoContentHttpClient(),
                                          requestConverter: RestingRequestConverter())

        let expectation = XCTestExpectation(description: "Send request")

        let endpoint = Endpoint<Nothing, SimpleModel?>(.get, "/", encoding: .query)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())

        restingClient
            .perform(request)
            .done { XCTAssertNil($0.body) }
            .assertSuccess()
            .finally(expectation.fulfill)

        wait(for: [expectation], timeout: 0.1)
    }

    func testBasicUpload() {
        let restingClient = RestingClient(baseUrl: "http://localhost",
                                          httpClient: EchoHttpClient(),
                                          requestConverter: RestingRequestConverter())

        let expectation = XCTestExpectation(description: "Send request")

        let endpoint = Endpoint<Nothing, Nothing>(.post, "/", encoding: .multipartFormData)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())

        var progressCalled = false

        restingClient
            .upload(request)
            .progress { _ in progressCalled = true }
            .assertSuccess()
            .finally(expectation.fulfill)

        wait(for: [expectation], timeout: 1.5)
        XCTAssertTrue(progressCalled)
    }

    func testUploadWithOptionalValue() {
        let restingClient = RestingClient(baseUrl: "http://localhost",
                                          httpClient: EchoHttpClient(),
                                          requestConverter: RestingRequestConverter())

        let expectation = XCTestExpectation(description: "Send request")

        let endpoint = Endpoint<Nothing, Nothing>(.post, "/", encoding: .multipartFormData)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())

        var progressCalled = false

        restingClient
            .upload(request)
            .progress { _ in progressCalled = true }
            .assertSuccess()
            .finally(expectation.fulfill)

        wait(for: [expectation], timeout: 1.5)
        XCTAssertTrue(progressCalled)
    }
}
