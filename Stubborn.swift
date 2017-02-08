
import Foundation

public class Stubborn {

    public typealias StubCallback = (Int) -> ([AnyHashable: Any])

    class Stub {

        private var numberOfRequests: Int = 0

        var url: String
        var callback: StubCallback

        fileprivate var data: Data? {
            self.numberOfRequests += 1
            let dict = self.callback(self.numberOfRequests)
            return try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        }

        init(url: String, callback: @escaping StubCallback) {
            self.url = url
            self.callback = callback
        }

    }

    class StubProtocol: URLProtocol {

        override static func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override static func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let url = self.request.url?.absoluteString else {
                return
            }
            
            for stub in Stubborn.shared.stubs {
                let range = (url as NSString).range(of: url)
                let regex = try? NSRegularExpression(pattern: stub.url, options: [])
                let match = (regex?.matches(in: url, options: [], range: range).count ?? 0) > 0
                if match, let data = stub.data {
                    let response = HTTPURLResponse(
                        url: self.request.url!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: [
                            "Content-Type": "application/json",
                            "Content-Length": String(data.count),
                            ]
                    )!
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                    self.client?.urlProtocol(self, didLoad: data)
                    self.client?.urlProtocolDidFinishLoading(self)
                    return
                }
            }

            let response = HTTPURLResponse(
                url: self.request.url!,
                statusCode: 400,
                httpVersion: nil,
                headerFields: [:]
            )!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocolDidFinishLoading(self)
        }

        override func stopLoading() {
            // Do nothing...
        }

    }

    private var stubs: [Stub] = []

    public static var shared: Stubborn = {
        return Stubborn()
    }()

    private init() {
        URLProtocol.registerClass(StubProtocol.self)
    }

    public func add(url: String, callback: @escaping StubCallback) {
        self.stubs.append(Stub(url: url, callback: callback))
    }

    public func reset() {
        self.stubs = []
    }

}
