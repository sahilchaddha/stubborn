
import Alamofire
import XCTest

@testable import Stubborn

class StubbornTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Stubborn.shared.reset()
    }
    
    func testSuccess() {
        Stubborn.shared.add(url: ".*/get") {
            XCTAssertEqual($0.method, "GET")
            XCTAssertNil($0.data)
            XCTAssertEqual($0.url.absoluteString, "https://httpbin.org/get")
            XCTAssertEqual($0.numberOfRequests, 1)
            
            return [
                "success": true
            ]
        }
        
        let expectation = self.expectation(description: "request")
        Alamofire.request("https://httpbin.org/get").responseJSON {
            switch $0.result {
            case .success(let value):
                guard let data = value as? [AnyHashable: Any] else {
                    return
                }
                XCTAssertTrue(data.keys.contains("success"))
                XCTAssertTrue(data["success"] as? Bool ?? false)
                expectation.fulfill()
            default:
                XCTAssertTrue(false)
            }
        }
        
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }
    
}
