
extension Stubborn {

    public class Stub {
        
        private var numberOfRequests: Int = 0
        
        var url: Request.URL
        var delay: Delay?
        var response: RequestResponse
        
        init(_ url: String, response: @escaping RequestResponse) {
            self.url = url
            self.response = response
        }
        
        convenience init(_ url: String, dictionary: Body.Dictionary) {
            self.init(url) { _ in dictionary }
        }
        
        convenience init(_ url: String, error: Body.Error) {
            self.init(url) { _ in error }
        }
        
        convenience init(_ url: String, resource: Body.Resource) {
            self.init(url) { _ in resource }
        }
        
        func loadBody(_ request: Request) -> Body {
            self.numberOfRequests += 1
            
            var request = request
            request.numberOfRequests = self.numberOfRequests
            
            return self.response(request)
        }
        
        func isStubbing(request: Request) -> Bool {
            return request.url =~ self.url
        }
        
    }
    
}

extension Stubborn.Stub: CustomStringConvertible {
    
    public var description: String {
        var description = "Stub({"
        description = "\(description)\n    Url: \(self.url)"
        description = "\(description)\n    Delay: \(self.delay)"
        description = "\(description)\n})"
        
        return description
    }
    
}

infix operator ⏱

@discardableResult
public func ⏱ (delay: Stubborn.Delay?, stub: Stubborn.Stub) -> Stubborn.Stub {
    stub.delay = delay
    return stub
}
