
extension Stubborn {

    public struct Resource {
        
        private let ext: String = "json"

        private var name: String
        private var bundle: Bundle = Bundle.main
        private var subpath: String?
        
        private var path: String? {
            return self.bundle.path(
                forResource: self.name,
                ofType: self.ext,
                inDirectory: self.subpath
            )
        }
        
        public init(_ resource: String, in bundle: Bundle = Bundle.main) {
            var pathComponents = resource.components(separatedBy: "/")
            
            self.name = pathComponents.popLast()!
            self.bundle = bundle
            self.subpath = pathComponents.joined(separator: "/")
        }
        
        var data: Data {
            guard let path = self.path else {
                fatalError("Couldn't find \(self.name).\(self.ext)")
            }
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
                fatalError("Couldn't load \(path)")
            }
            return data
        }
        
        public var exists: Bool {
            return self.path != nil
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
