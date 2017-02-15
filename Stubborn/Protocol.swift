
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
        Stubborn.log("startLoading", level: .verbose)
        
        let request = self.stubbornRequest
        
        let stubs = Stubborn.stubs.reversed()
        for stub in stubs {
            guard let response = Stubborn.Response(request: request, stub: stub) else {
                continue
            }
            
            Stubborn.log("handle request: <\(request)> with stub <\(stub)>")
            
            return self.respond(response, delay: stub.delay)
        }
        
        Stubborn.log("unhandled request: <\(request)>")
        Stubborn.unhandledRequestResponse?(request)
        
        self.respond(Stubborn.Response(request: request), delay: nil)
    }
    
    override func stopLoading() {
        // Do nothing...
    }
    
    private func respond(_ response: Stubborn.Response, delay: Stubborn.Delay?) {
        self.client?.urlProtocol(self, didReceive: response.response, cacheStoragePolicy: .notAllowed)
        self.client?.urlProtocol(self, didLoad: response.data)
        if let error = response.error {
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
        
        delay?.asyncAfter(fire) ?? fire()
    }
    
}
