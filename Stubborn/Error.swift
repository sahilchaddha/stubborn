
extension Stubborn {

    public struct Error {
        
        public typealias StatusCode = Int

        public var statusCode: StatusCode
        public var description: String
        
        public init(statusCode: StatusCode, description: String) {
            self.statusCode = statusCode
            self.description = description
        }
        
        private var body: Body {
            return ["error": self.description]
        }
        
        var data: Data {
            return self.body.data
        }
        
        var error: Swift.Error? {
            return NSError(domain: "Error", code: self.statusCode, userInfo: [
                NSLocalizedDescriptionKey: self.description
            ])
        }
        
    }

}
