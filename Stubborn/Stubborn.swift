
import Foundation

public typealias StubbornData = [AnyHashable: Any]
public typealias StubbornResponse = (StubbornRequest) -> (StubbornData)

public class Stubborn {

    var stubs: [StubbornStub] = []

    public static var shared: Stubborn = {
        return Stubborn()
    }()

    private init() {
        let protocolClasses = [StubbornProtocol.self] as [AnyClass]
        for protocolClass in protocolClasses {
            URLProtocol.registerClass(protocolClass)
        }
        
        URLSessionConfiguration.swizzle()
    }

    public func add(url: String, delay: TimeInterval? = nil, callback: @escaping StubbornResponse) {
        self.stubs.append(
            StubbornStub(
                url: url,
                delay: delay,
                callback: callback
            )
        )
    }

    public func reset() {
        self.stubs = []
    }

}
