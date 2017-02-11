
extension Stubborn {

    public class Stub {
        
        private var numberOfRequests: Int = 0
        
        var url: String
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
