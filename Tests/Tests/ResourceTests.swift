
import Stubborn
import XCTest

class ResourceTests: XCTestCase {
    
    func testExists() {
        let bundle = Bundle(for: ResourceTests.self)
        XCTAssertFalse(Stubborn.Resource("ResponseFile").exists)
        XCTAssertFalse(Stubborn.Resource("ResponseFileX", in: bundle).exists)
        XCTAssertTrue(Stubborn.Resource("ResponseFile", in: bundle).exists)
        XCTAssertFalse(Stubborn.Resource("ResourcesX/ResponseFile", in: bundle).exists)
        XCTAssertTrue(Stubborn.Resource("Resources/ResponseFile", in: bundle).exists)
    }
    
}
