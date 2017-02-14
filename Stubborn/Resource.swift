
extension Stubborn {

    public struct Resource {
        
        private let ext: String = "json"

        fileprivate var name: String
        fileprivate var bundle: Bundle = Bundle.main
        fileprivate var subpath: String?
        
        public init(_ resource: String, in bundle: Bundle = Bundle.main) {
            var pathComponents = resource.components(separatedBy: "/")
            
            self.name = pathComponents.popLast()!
            self.bundle = bundle
            self.subpath = pathComponents.joined(separator: "/")
        }
        
        var data: Data {
            guard let path = self.bundle.path(
                forResource: self.name,
                ofType: self.ext,
                inDirectory: self.subpath
            ) else {
                fatalError("Couldn't find \(self.name).\(self.ext)")
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
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
}
