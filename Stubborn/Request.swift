
import QueryString

extension Stubborn {

    public struct Request {
        
        public typealias Method = String
        public typealias URL = String
        public typealias StatusCode = Int
        
        public var method: Method? // TODO: make enum
        public var url: URL
        public var queryString: QueryString?
        public var body: Body.Dictionary?
        public var headers: Body.Headers?
        public var numberOfRequests: Int?
        
        init(request: URLRequest) {
            self.method = request.httpMethod
            self.url = request.url!.absoluteString
            self.queryString = QueryString(url: &self.url)
            self.body = Body.Dictionary(request.httpBody)
            self.headers = Body.Headers(request.allHTTPHeaderFields)
        }
        
    }

}

extension Stubborn.Request: CustomStringConvertible {
    
    public var description: String {
        let nilString = "<nil>"
        
        var description = "Request({"
        description = "\(description)\n    Method: \(self.method ?? nilString)"
        description = "\(description)\n    Url: \(self.url)"
        description = "\(description)\n    QueryString: \(self.queryString ?? QueryString())"
        description = "\(description)\n    Body: \(self.body ?? Stubborn.Body.Dictionary())"
        description = "\(description)\n    Headers: \(self.headers ?? Stubborn.Body.Headers())"
        description = "\(description)\n    NumberOfRequests: \(self.numberOfRequests ?? 0)"
        description = "\(description)\n})"
        
        return description
    }
    
}
