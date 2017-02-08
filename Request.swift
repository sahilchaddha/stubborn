
public struct StubbornRequest {
    
    public var method: String? // TODO: make enum
    public var url: URL
    public var data: StubbornData?
    public var queryString: String? // TODO: add pod dependency
    public var numberOfRequests: Int = 0
    
    init?(request: URLRequest) {
        guard let url = request.url else {
            return nil
        }
        
        self.method = request.httpMethod
        self.url = url
        
        if let body = request.httpBody,
            let data = try? JSONSerialization.jsonObject(with: body, options: []) {
            self.data = data as? StubbornData
        }
    }
    
    private func match(stub: StubbornStub) -> Bool {
        // TODO: make nicer
        let url = self.url.absoluteString
        let range = (url as NSString).range(of: url)
        let regex = try? NSRegularExpression(pattern: stub.url, options: [])
        return (regex?.matches(in: url, options: [], range: range).count ?? 0) > 0
    }
    
    func response(for stub: StubbornStub) -> (HTTPURLResponse, Data)? {
        guard self.match(stub: stub), let data = stub.data(for: self) else {
            return nil
        }
        let response = HTTPURLResponse(
            url: self.url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Content-Type": "application/json",
                "Content-Length": String(data.count),
            ]
        )!
        return (response, data)
    }
    
}
