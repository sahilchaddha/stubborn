
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
            
            let fire: () -> () = { [weak self] in
                guard let this = self else {
                    return
                }
                this.client?.urlProtocolDidFinishLoading(this)
            }
            
            if let delay = stub.delay {
                let deadline = DispatchTime.now() + delay
                DispatchQueue.main.asyncAfter(deadline: deadline, execute: fire)
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
