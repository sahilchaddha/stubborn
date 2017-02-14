
import Alamofire
import Stubborn
import XCTest

class StubbornTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        Stubborn.reset()
    }
    
    func testStart() {
        let expectation0 = self.expectation(description: "request0")
        Stubborn.unhandledRequest { _ in
            expectation0.fulfill()
        }
        
        let expectation1 = self.expectation(description: "request1")
        _ = SessionManager().request("https://httpbin.org/get").responseJSON { _ in
            expectation1.fulfill()
        }
        
        Stubborn.start()
        
        let expectation2 = self.expectation(description: "request2")
        _ = SessionManager().request("https://httpbin.org/get").responseJSON { _ in
            expectation2.fulfill()
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testStop() {
        let expectation0 = self.expectation(description: "request0")
        Stubborn.add(url: ".*/get") { request -> (Stubborn.Body) in
            expectation0.fulfill()
            return [:]
        }
        
        let expectation1 = self.expectation(description: "request1")
        _ = SessionManager().request("https://httpbin.org/get").responseJSON { _ in
            expectation1.fulfill()
        }
        
        Stubborn.stop()
        
        let expectation2 = self.expectation(description: "request2")
        _ = SessionManager().request("https://httpbin.org/get").responseJSON { _ in
            expectation2.fulfill()
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSuccess() {
        Stubborn.add(url: ".*/get") { request -> (Stubborn.Body) in
            XCTAssertEqual(request.method, "GET")
            XCTAssertNil(request.body)
            XCTAssertEqual(request.url, "https://httpbin.org/get")
            XCTAssertEqual(request.numberOfRequests, 1)
            
            return [
                "success": true
            ]
        }
        
        let expectation = self.expectation(description: "request")
        Alamofire.request("https://httpbin.org/get").responseJSON {
            XCTAssertEqual($0.response?.statusCode, 200)
            
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
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFailure() {
        Stubborn.add(url: ".*/get") { _ in
            return Stubborn.Error(
                statusCode: 400,
                description: "Something went wrong"
            )
        }
        
        let expectation = self.expectation(description: "request")
        Alamofire.request("https://httpbin.org/get").responseJSON {
            XCTAssertEqual($0.response?.statusCode, 400)
            
            switch $0.result {
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Something went wrong")
                expectation.fulfill()
            default:
                XCTAssertTrue(false)
            }
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testNumberOfRequests() {
        let expectation1 = self.expectation(description: "request1")
        let expectation2 = self.expectation(description: "request2")
        let expectation3 = self.expectation(description: "request3")
        Stubborn.add(url: ".*/get") { request -> (Stubborn.Body) in
            switch request.numberOfRequests! {
            case 1:
                expectation1.fulfill()
            case 2:
                expectation2.fulfill()
            case 3:
                expectation3.fulfill()
            default:
                XCTAssertTrue(false)
            }
            
            return ["success": true]
        }
        
        _ = Alamofire.request("https://httpbin.org/get")
        _ = Alamofire.request("https://httpbin.org/get")
        _ = Alamofire.request("https://httpbin.org/get")
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequestBody() {
        // TODO: doesn't seem to be able to pass the body with the request??
        //    let expectation = self.expectation(description: "request")
        //    Stubborn.add(url: ".*/post") { request -> (Stubborn.Body) in
        //        XCTAssertEqual(request.body?["Page"] as? Int, 1)
        //        expectation.fulfill()
        //        
        //        return ["success": true]
        //    }
        //    
        //    _ = Alamofire.request("https://httpbin.org/post", method: .post, parameters: [
        //        "Page": 1
        //    ])
        //    
        //    self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testRequestHeader() {
        let expectation = self.expectation(description: "request")
        Stubborn.add(url: ".*/get") { request -> (Stubborn.Body) in
            XCTAssertEqual(request.headers?["X-Custom-Header"] as? String, "1")
            expectation.fulfill()
            
            return ["success": true]
        }
        
        _ = Alamofire.request("https://httpbin.org/get", headers: [
            "X-Custom-Header": "1"
        ])
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testQueryString() {
        let expectation = self.expectation(description: "request")
        Stubborn.add(url: ".*/get") { request -> (Stubborn.Body) in
            XCTAssertEqual(request.queryString?.description, "query=stockholm")
            expectation.fulfill()
            
            return ["success": true]
        }
        
        _ = Alamofire.request("https://httpbin.org/get", parameters: ["query": "stockholm"])
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testDelay() {
        1 ⏱ Stubborn.add(url: ".*/get") { _ in
            return ["success": true]
        }
        
        let startTime = Date().timeIntervalSince1970
        let expectation = self.expectation(description: "request")
        Alamofire.request("https://httpbin.org/get").responseJSON { _ in
            XCTAssertGreaterThan(Date().timeIntervalSince1970 - startTime, 1)
            XCTAssertLessThan(Date().timeIntervalSince1970 - startTime, 1.2)
            expectation.fulfill()
        }
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testResource() {
        let bundle = Bundle(for: self.classForCoder)
        Stubborn.add(url: ".*/get", resource: Stubborn.Resource("ResponseFile", in: bundle))
        
        let expectation = self.expectation(description: "request")
        Alamofire.request("https://httpbin.org/get").responseJSON {
            XCTAssertEqual($0.response?.statusCode, 200)
            
            switch $0.result {
            case .success(let value):
                guard let data = value as? [AnyHashable: Any] else {
                    return
                }
                XCTAssertTrue(data.keys.contains("isFile"))
                XCTAssertTrue(data["isFile"] as? Bool ?? false)
                expectation.fulfill()
            default:
                XCTAssertTrue(false)
            }
        }
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testResourceSubpathed() {
        let bundle = Bundle(for: self.classForCoder)
        Stubborn.add(
            url: ".*/get",
            resource: Stubborn.Resource("Resources/ResponseFile", in: bundle)
        )
        
        let expectation = self.expectation(description: "request")
        Alamofire.request("https://httpbin.org/get").responseJSON {
            XCTAssertEqual($0.response?.statusCode, 200)
            
            switch $0.result {
            case .success(let value):
                guard let data = value as? [AnyHashable: Any] else {
                    return
                }
                XCTAssertTrue(data.keys.contains("isFile"))
                XCTAssertTrue(data["isFile"] as? Bool ?? false)
                expectation.fulfill()
            default:
                XCTAssertTrue(false)
            }
        }
        
        self.waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testUnhandledRequest() {
        let expectation1 = self.expectation(description: "request1")
        Stubborn.unhandledRequest { request in
            XCTAssertEqual(request.method, "GET")
            XCTAssertNil(request.body)
            XCTAssertEqual(request.url, "https://httpbin.org/get")
            XCTAssertNil(request.numberOfRequests)
            expectation1.fulfill()
        }
        
        let expectation2 = self.expectation(description: "request2")
        Alamofire.request("https://httpbin.org/get").responseJSON {
            XCTAssertEqual($0.response?.statusCode, 200)
            
            switch $0.result {
            case .success(let value):
                guard let data = value as? [AnyHashable: Any] else {
                    return
                }
                XCTAssertTrue(data.isEmpty)
                expectation2.fulfill()
            default:
                XCTAssertTrue(false)
            }
        }
        
        self.waitForExpectations(timeout: 1, handler: nil)
    }
    
}
