
extension Stubborn {

    public struct Error {
        
        public typealias StatusCode = Int

        var statusCode: StatusCode
        var description: String
        
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
