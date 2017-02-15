
class StubbornProtocol: URLProtocol {
    
    static func register() {
        URLProtocol.registerClass(self)
        URLSessionConfiguration.registerStubborn()
    }
    
    static func unregister() {
        URLProtocol.unregisterClass(self)
        URLSessionConfiguration.unregisterStubborn()
    }
    
    private var stubbornRequest: Stubborn.Request {
        return Stubborn.Request(request: self.request)
    }
    
    override static func canInit(with request: URLRequest) -> Bool {
        return request.url != nil
    }
    
    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        Stubborn.shared.log("startLoading", level: .verbose)
        
        let request = self.stubbornRequest
        
        let stubs = Stubborn.shared.reversed()
        for stub in stubs {
            guard let response = request.response(for: stub) else {
                continue
            }
            
            Stubborn.shared.log("handle request: <\(request)> with stub <\(stub)>")
            
            return self.respond(with: response, and: stub.delay)
        }
        
        Stubborn.shared.log("unhandled request: <\(request)>")
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
