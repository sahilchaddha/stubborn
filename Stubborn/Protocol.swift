
class StubbornProtocol: URLProtocol {
    
    private var stubbornRequest: Stubborn.Request? {
        return Stubborn.Request(request: self.request)
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
        
        for stub in Stubborn.shared {
            guard let (response, data, error) = request.response(for: stub) else {
                continue
            }
            
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: data)
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
            
            let fire: () -> () = { [weak self] in
                guard let this = self else {
                    return
                }
                this.client?.urlProtocolDidFinishLoading(this)
            }
            
            if let delay = stub.delay {
                delay.asyncAfter(fire)
            } else {
                fire()
            }
            
            break
        }
    }
    
    override func stopLoading() {
        // Do nothing...
    }
    
}
