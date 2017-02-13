
import Foundation

public class Stubborn {
    
    public typealias SuccessResponse = (Request) -> (Body)
    public typealias FailureResponse = (Request) -> (Error)
    public typealias UnhandledRequestResponse = (Request) -> ()
    
    fileprivate var isOn: Bool = false
    fileprivate var stubs: [Stub] = []
    private(set) var unhandledRequestResponse: UnhandledRequestResponse?

    static var shared: Stubborn = {
        return Stubborn()
    }()

    private init() {
        // Do nothing...
    }
    
    @discardableResult
    fileprivate func add(url: String, response: @escaping SuccessResponse) -> Stub {
        let stub = Stub(url)
        stub.successResponse = response
        return self.add(stub: stub)
    }
    
    @discardableResult
    fileprivate func add(url: String, response: @escaping FailureResponse) -> Stub {
        let stub = Stub(url)
        stub.failureResponse = response
        return self.add(stub: stub)
    }
    
    @discardableResult
    fileprivate func add(url: String, resource: Resource) -> Stub {
        let stub = Stub(url)
        stub.resource = resource
        return self.add(stub: stub)
    }
    
    fileprivate func add(stub: Stub) -> Stub {
        self.start()
        
        self.stubs.append(stub)
        
        return stub
    }
    
    fileprivate func unhandledRequest(_ response: @escaping UnhandledRequestResponse) {
        self.unhandledRequestResponse = response
    }
    
    fileprivate func start() {
        guard !self.isOn else {
            return
        }
        
        self.isOn = true
        
        StubbornProtocol.register()
    }
    
    fileprivate func stop() {
        guard self.isOn else {
            return
        }
        
        self.isOn = false
        
        StubbornProtocol.unregister()
    }
    
    fileprivate func reset() {
        self.stubs = []
        self.stop()
    }

}

extension Stubborn {
    
    public static var isOn: Bool {
        return self.shared.isOn
    }
    
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
    
    public static func unhandledRequest(_ response: @escaping UnhandledRequestResponse) {
        self.shared.unhandledRequest(response)
    }
    
    public static func start() {
        self.shared.start()
    }
    
    public static func stop() {
        self.shared.stop()
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
