
class StubbornProtocol: URLProtocol {
    
    private var stubbornRequest: StubbornRequest? {
        return StubbornRequest(request: self.request)
    }
    
    override static func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let request = self.stubbornRequest else {
            return
        }
        
        for stub in Stubborn.shared.stubs {
            guard let (response, data) = request.response(for: stub) else {
                continue
            }
            
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            self.client?.urlProtocolDidFinishLoading(self)
            
            break
        }
    }
    
    override func stopLoading() {
        // Do nothing...
    }
    
}
