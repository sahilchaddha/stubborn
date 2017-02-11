
extension Stubborn {

    public struct Delay {
        
        fileprivate var delay: TimeInterval
        
        init(_ delay: TimeInterval) {
            self.delay = delay
        }
        
        func asyncAfter(_ fire: @escaping () -> ()) {
            DispatchQueue.main.asyncAfter(
                deadline: DispatchTime.now() + self.delay,
                execute: fire
            )
        }
        
    }
    
}

extension Stubborn.Delay: ExpressibleByFloatLiteral {
    
    public typealias FloatLiteralType = TimeInterval
    
    public init(floatLiteral value: TimeInterval) {
        self.delay = value
    }
    
}

extension Stubborn.Delay: ExpressibleByIntegerLiteral {
    
    public typealias IntegerLiteralType = TimeInterval
    
    public init(integerLiteral value: TimeInterval) {
        self.delay = value
    }
    
}

public func + (lhs: Stubborn.Delay, rhs: Stubborn.Delay) -> Stubborn.Delay {
    return Stubborn.Delay(lhs.delay + rhs.delay)
}

infix operator ⏱

@discardableResult
public func ⏱ (delay: Stubborn.Delay, stub: Stubborn.Stub) -> Stubborn.Stub {
    stub.delay = (stub.delay ?? 0) + delay
    return stub
}
