import XCTest
import RestingKit

class Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let client = RestingClient(baseUrl: "http://example.com", decoder: JSONDecoder(), httpClient: EmptyHTTPClient(), requestConverter: RestingRequestConverter(jsonEncoder: JSONEncoder(), jsonDecoder: JSONDecoder()))
        let endpoint = Endpoint<Nothing, Nothing>(path: "/", method: .get, encoding: .json)
        let request = RestingRequest(endpoint: endpoint, body: Nothing())
        client.perform(request).done { _ in

        }.catch { error in
            XCTFail("Expected call to succeed but failed with error \(error)")
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
