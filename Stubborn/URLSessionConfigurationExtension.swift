
extension URLSessionConfiguration {
    
    class func swizzle() {
        swizzleDefault()
        swizzleEphemeral()
    }
    
    private func appendStubbornProtocol() -> URLSessionConfiguration {
        let stubbornProtocolClasses = [StubbornProtocol.self] as [AnyClass]
        self.protocolClasses = stubbornProtocolClasses + self.protocolClasses!
        return self
    }
    
    @objc fileprivate class func stubborn_default() -> URLSessionConfiguration {
        return stubborn_default().appendStubbornProtocol()
    }
    
    @objc fileprivate class func stubborn_ephemeral() -> URLSessionConfiguration {
        return stubborn_ephemeral().appendStubbornProtocol()
    }
    
    fileprivate static func exchange(_ selector: Selector, with replacementSelector: Selector) {
        let method = class_getClassMethod(self, selector)
        let replacementMethod = class_getClassMethod(self, replacementSelector)
        method_exchangeImplementations(method, replacementMethod)
    }

}

private let swizzleDefault: () -> () = {
    let selector = #selector(getter: URLSessionConfiguration.default)
    let stubbornSelector = #selector(URLSessionConfiguration.stubborn_default)
    URLSessionConfiguration.exchange(selector, with: stubbornSelector)
}

private let swizzleEphemeral: () -> () = {
    let selector = #selector(getter: URLSessionConfiguration.ephemeral)
    let stubbornSelector = #selector(URLSessionConfiguration.stubborn_ephemeral)
    URLSessionConfiguration.exchange(selector, with: stubbornSelector)
}
