
extension Stubborn {
    
    public struct Body {
        
        typealias InternalBody = [Key: Value]
        
        fileprivate var body: InternalBody
        
        var data: Data {
            guard let data = try? JSONSerialization.data(withJSONObject: self.body, options: []) else {
                fatalError("Couldn't parse data")
            }
            return data
        }
        
        init?(_ body: InternalBody?) {
            guard let body = body else {
                return nil
            }
            self.body = body
        }
        
        init?(_ body: Any?) {
            self.init(body as? InternalBody)
        }
        
        init?(_ data: Data?) {
            guard let data = data,
                let body = try? JSONSerialization.jsonObject(with: data, options: []) else {
                return nil
            }
            self.init(body)
        }
        
    }

}

extension Stubborn.Body: CustomStringConvertible {
    
    public var description: String {
        return "Body(\(self.body))"
    }
    
}

extension Stubborn.Body: ExpressibleByDictionaryLiteral {
    
    public typealias Key = AnyHashable
    public typealias Value = Any
    
    public init(dictionaryLiteral elements: (Stubborn.Body.Key, Stubborn.Body.Value)...) {
        self.body = [:]
        for (key, value) in elements {
            self.body[key] = value
        }
    }
    
}

extension Stubborn.Body: Collection {
    
    public typealias Index = DictionaryIndex<Key, Value>
    
    public var startIndex: Index {
        return self.body.startIndex
    }
    
    public var endIndex: Index {
        return self.body.endIndex
    }
    
    public func index(after index: Index) -> Index {
        return self.body.index(after: index)
    }
    
    public subscript(index: Index) -> (key: Key, value: Value) {
        return self.body[index]
    }
    
    public subscript(index: String) -> Any? {
        return self.body[index]
    }
    
}
