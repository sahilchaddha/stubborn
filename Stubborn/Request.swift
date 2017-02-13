
import QueryString

extension Stubborn {
    
    typealias Response = (HTTPURLResponse, Data, Swift.Error?)

    public struct Request {
        
        public typealias Method = String
        public typealias URL = String
        
        public var method: Method? // TODO: make enum
        public var url: URL
        public var body: Body?
        public var headers: Body?
        public var queryString: QueryString?
        public var numberOfRequests: Int?
        
        init(request: URLRequest) {
            self.method = request.httpMethod
            self.url = request.url!.absoluteString
            self.body = Body(request.httpBody)
            self.headers = Body(request.allHTTPHeaderFields)
            self.queryString = QueryString(url: &self.url)
        }
        
        private func match(stub: Stub) -> Bool {
            return self.url =~ stub.url
        }
        
        var response: Response {
            let data = Body([:])!.data
            let response = self.response(statusCode: 200, data: data)
            return (response, data, nil)
        }
        
        func response(for stub: Stubborn.Stub) -> Response? {
            guard self.match(stub: stub) else {
                return nil
            }
            let (data, error) = stub.loadData(self)
            if let data = data {
                let response = self.response(statusCode: 200, data: data)
                return (response, data, nil)
            } else if let error = error {
                let data = error.data
                let response = self.response(statusCode: error.statusCode, data: data)
                return (response, data, error.error)
            } else {
                return nil
            }
        }
        
        private func response(statusCode: Int, data: Data) -> HTTPURLResponse {
            return HTTPURLResponse(
                url: Foundation.URL(string: self.url)!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: [
                    "Content-Type": "application/json",
                    "Content-Length": String(data.count),
                ]
            )!
        }
        
    }

}
