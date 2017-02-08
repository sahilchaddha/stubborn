
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
        
        URLSessionConfiguration.stubbornSwizzleDefaultSessionConfiguration()
    }

    public func add(url: String, callback: @escaping StubbornResponse) {
        self.stubs.append(
            StubbornStub(
                url: url,
                callback: callback
            )
        )
    }

    public func reset() {
        self.stubs = []
    }

}

let swizzleDefaultSessionConfiguration: Void = {
    
    let defaultSessionConfiguration = class_getClassMethod(
        URLSessionConfiguration.self,
        #selector(getter: URLSessionConfiguration.default)
    )
    let stubbornDefaultSessionConfiguration = class_getClassMethod(
        URLSessionConfiguration.self,
        #selector(URLSessionConfiguration.stubbornDefaultSessionConfiguration)
    )
    method_exchangeImplementations(
        defaultSessionConfiguration,
        stubbornDefaultSessionConfiguration
    )
    
    let ephemeralSessionConfiguration = class_getClassMethod(
        URLSessionConfiguration.self,
        #selector(getter: URLSessionConfiguration.ephemeral)
    )
    let stubbornEphemeralSessionConfiguration = class_getClassMethod(
        URLSessionConfiguration.self,
        #selector(URLSessionConfiguration.stubbornEphemeralSessionConfiguration)
    )
    method_exchangeImplementations(
        ephemeralSessionConfiguration,
        stubbornEphemeralSessionConfiguration
    )
}()

extension URLSessionConfiguration {
    /// Swizzles NSURLSessionConfiguration's default and ephermeral sessions to add Stubborn
    public class func stubbornSwizzleDefaultSessionConfiguration() {
        _ = swizzleDefaultSessionConfiguration
    }
    
    class func stubbornDefaultSessionConfiguration() -> URLSessionConfiguration {
        let configuration = stubbornDefaultSessionConfiguration()
        configuration.protocolClasses = [StubbornProtocol.self] as [AnyClass] + configuration.protocolClasses!
        return configuration
    }
    
    class func stubbornEphemeralSessionConfiguration() -> URLSessionConfiguration {
        let configuration = stubbornEphemeralSessionConfiguration()
        configuration.protocolClasses = [StubbornProtocol.self] as [AnyClass] + configuration.protocolClasses!
        return configuration
    }
}
