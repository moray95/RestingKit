//
//  IntegrationTests.swift
//  RestingKitTests
//
//  Created by Moray Baruh on 21.11.2019.
//  Copyright © 2019 Moray Baruh. All rights reserved.
//

import XCTest
import RestingKit

class RestingClientIntegrationTests: XCTestCase {
    enum Endpoints {
        static let list = Endpoint<Nothing, [PostModel]>(.get, "/", encoding: .query)
        static let get = Endpoint<Nothing, PostModel>(.get, "/{{post_id}}", encoding: .query)
        static let create  = Endpoint<PostCreateModel, PostModel>(.post, "/", encoding: .json)

        static let upload = Endpoint<ImageUploadModel, Nothing>(.post, "/", encoding: .multipartFormData)
    }

    var jsonClient: RestingClient!
    var uploadClient: RestingClient!

    let timeout: TimeInterval = 2

    override func setUp() {
        let configuration = RestingRequestConverter.Configuration(contextPath: "/posts")
        jsonClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                   requestConverter: RestingRequestConverter(configuration: configuration))

        uploadClient = RestingClient(baseUrl: "http://localhost:9000", requestConverter: RestingRequestConverter())
    }

    override func tearDown() {
        jsonClient = nil
        uploadClient = nil
    }

    func testCanPerformGet() {
        let request = RestingRequest(endpoint: Endpoints.get, body: Nothing(), pathVariables: ["post_id": 42])

        jsonClient
            .perform(request)
            .assertSuccess()
            .waitForTesting(in: self, timeout: timeout)
    }

    func testCanPerformPost() {
        let body = PostCreateModel(userId: 42, title: "Hello RestingKit", body: "Awesome RestingKit test.. Take a look!")
        let request = RestingRequest(endpoint: Endpoints.create, body: body)

        jsonClient
            .perform(request)
            .assertSuccess()
            .waitForTesting(in: self, timeout: timeout)
    }

    func testCanUploadFile() {
        let body = ImageUploadModel(imageURL: Bundle(for: type(of: self)).url(forResource: "sample", withExtension: "jpg")!)
        let request = RestingRequest(endpoint: Endpoints.upload, body: body)

        var progressCalled = false

        uploadClient.upload(request)
            .progress { _ in progressCalled = true }
            .assertSuccess()
            .waitForTesting(in: self)

        XCTAssertTrue(progressCalled)
    }
}
