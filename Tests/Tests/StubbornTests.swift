
import XCTest

@testable import Stubborn

class StubbornTests: XCTestCase {
    
    func test() {
        Stubborn.shared.reset()
        Stubborn.shared.add(url: "/users") { _ in
            return [:]
        }
    }
    
}
