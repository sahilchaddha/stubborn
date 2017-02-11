
extension Stubborn {

    public struct Resource {

        fileprivate var resource: String
        fileprivate var bundle: Bundle = Bundle.main
        
        init(_ resource: String, in bundle: Bundle = Bundle.main) {
            self.resource = resource
            self.bundle = bundle
        }
        
        var data: Data {
            guard let path = self.bundle.path(forResource: self.resource, ofType: "json") else {
                fatalError("Couldn't find \(self.resource).json")
            }
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                fatalError("Couldn't load \(path)")
            }
            return data
        }
        
    }

}

extension Stubborn.Resource: ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String
    
    public init(stringLiteral value: String) {
        self.resource = value
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.resource = value
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.resource = value
    }
    
}
