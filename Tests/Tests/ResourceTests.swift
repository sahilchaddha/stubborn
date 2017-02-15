
import Stubborn
import XCTest

class ResourceTests: XCTestCase {
    
    func testExists() {
        let bundle = Bundle(for: ResourceTests.self)
        XCTAssertFalse(Stubborn.Body.Resource("ResponseFile").exists)
        XCTAssertFalse(Stubborn.Body.Resource("ResponseFileX", in: bundle).exists)
        XCTAssertTrue(Stubborn.Body.Resource("ResponseFile", in: bundle).exists)
        XCTAssertFalse(Stubborn.Body.Resource("ResourcesX/ResponseFile", in: bundle).exists)
        XCTAssertTrue(Stubborn.Body.Resource("Resources/ResponseFile", in: bundle).exists)
    }
    
}
