
extension Stubborn {

    public class Stub {
        
        private var numberOfRequests: Int = 0
        
        var url: Request.URL
        var delay: Delay?
        var successResponse: SuccessResponse?
        var failureResponse: FailureResponse?
        var resource: Resource?
        
        public init(_ url: String) {
            self.url = url
        }
        
        func loadData(_ request: Request) -> (Data?, Error?) {
            self.numberOfRequests += 1
            
            var request = request
            request.numberOfRequests = self.numberOfRequests
            
            if let response = self.successResponse {
                return (response(request).data, nil)
            } else if let response = self.failureResponse {
                return (nil, response(request))
            } else if let resource = self.resource {
                return (resource.data, nil)
            }
        
            fatalError("No available data")
        }
        
    }
    
}

extension Stubborn.Stub: CustomStringConvertible {
    
    public var description: String {
        var description = "Stub({"
        description = "\(description)\n    Url: \(self.url)"
        description = "\(description)\n    Delay: \(self.delay)"
        
        if let _ = self.successResponse {
            description = "\(description)\n    Type: Success"
        } else if let _ = self.failureResponse {
            description = "\(description)\n    Type: Error"
        } else if let resource = self.resource {
            description = "\(description)\n    Type: \(resource)"
        }
        
        description = "\(description)\n})"
        
        return description
    }
    
}
