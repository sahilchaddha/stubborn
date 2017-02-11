
import Foundation

public class Stubborn {
    
    public typealias SuccessResponse = (Request) -> (Body)
    public typealias FailureResponse = (Request) -> (Error)

    fileprivate var stubs: [Stub] = []

    static var shared: Stubborn = {
        return Stubborn()
    }()

    private init() {
        let protocolClasses = [StubbornProtocol.self] as [AnyClass]
        for protocolClass in protocolClasses {
            URLProtocol.registerClass(protocolClass)
        }
        
        URLSessionConfiguration.swizzle()
    }
    
    @discardableResult
    fileprivate func add(url: String, response: @escaping SuccessResponse) -> Stub {
        let stub = Stub(url)
        stub.successResponse = response
        
        self.stubs.append(stub)
        
        return stub
    }
    
    @discardableResult
    fileprivate func add(url: String, response: @escaping FailureResponse) -> Stub {
        let stub = Stub(url)
        stub.failureResponse = response
        
        self.stubs.append(stub)
        
        return stub
    }
    
    @discardableResult
    fileprivate func add(url: String, resource: Resource) -> Stub {
        let stub = Stub(url)
        stub.resource = resource
        
        self.stubs.append(stub)
        
        return stub
    }
    
    fileprivate func reset() {
        self.stubs = []
    }

}

extension Stubborn {
    
    @discardableResult
    public static func add(url: String, response: @escaping SuccessResponse) -> Stub {
        return self.shared.add(url: url, response: response)
    }
    
    @discardableResult
    public static func add(url: String, response: @escaping FailureResponse) -> Stub {
        return self.shared.add(url: url, response: response)
    }
    
    @discardableResult
    public static func add(url: String, resource: Resource) -> Stub {
        return self.shared.add(url: url, resource: resource)
    }
    
    public static func reset() {
        self.shared.reset()
    }
    
}

extension Stubborn: Collection {
    
    public typealias Index = Int
    
    public var startIndex: Index {
        return self.stubs.startIndex
    }
    
    public var endIndex: Index {
        return self.stubs.endIndex
    }
    
    public func index(after index: Index) -> Index {
        return self.stubs.index(after: index)
    }
    
    public subscript(index: Index) -> Stub {
        return self.stubs[index]
    }
    
}
