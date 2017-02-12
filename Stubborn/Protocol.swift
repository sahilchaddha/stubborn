
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
            guard let response = request.response(for: stub) else {
                continue
            }
            
            self.respond(with: response, and: stub.delay)
            
            return
        }
        
        Stubborn.shared.unhandledRequestResponse?(request)
        
        self.respond(with: request.response, and: nil)
    }
    
    override func stopLoading() {
        // Do nothing...
    }
    
    private func respond(with response: Stubborn.Response, and delay: Stubborn.Delay?) {
        let (response, data, error) = response
        
        self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: data)
        if let error = error {
            self.client?.urlProtocol(self, didFailWithError: error)
        }
        
        self.fire(with: delay)
    }
    
    private func fire(with delay: Stubborn.Delay?) {
        let fire: () -> () = { [weak self] in
            guard let this = self else {
                return
            }
            this.client?.urlProtocolDidFinishLoading(this)
        }
        
        if let delay = delay {
            delay.asyncAfter(fire)
        } else {
            fire()
        }
    }
    
}
