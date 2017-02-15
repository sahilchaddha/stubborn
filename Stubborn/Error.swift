
extension Stubborn {

    public struct Error {

        public var statusCode: Request.StatusCode
        public var message: String
        
        public init(_ statusCode: Request.StatusCode, _ message: String) {
            self.statusCode = statusCode
            self.message = message
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

extension Stubborn.Error: CustomStringConvertible {
    
    public var description: String {
        var description = "Error({"
        description = "\(description)\n    StatusCode: \(self.statusCode)"
        description = "\(description)\n    Message: \(self.message)"
        description = "\(description)\n})"
        
        return description
    }
    
}
