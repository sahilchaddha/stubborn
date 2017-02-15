![](logo.png)

[![](https://img.shields.io/badge/contact-@thematerik-blue.svg?style=flat-square)](http://twitter.com/thematerik)
[![](https://img.shields.io/cocoapods/v/Stubborn.svg?style=flat-square)](https://cocoapods.org/pods/Stubborn)
[![](https://img.shields.io/travis/materik/stubborn.svg?style=flat-square)](https://travis-ci.org/materik/stubborn)
![](https://img.shields.io/cocoapods/p/Stubborn.svg?style=flat-square)
![](https://img.shields.io/cocoapods/l/Stubborn.svg?style=flat-square)

Simple HTTP mocking framework.

## Install

```bash
pod 'Stubborn'
```

## Usage

### Start

This is done automatically when you add a stub

```swift
Stubborn.start()
```

### Success

```swift
Stubborn.add(url: ".*/users") { request in
    print(request.method)
    print(request.url)
    print(request.body)
    print(request.headers)
    print(request.queryString)
    print(request.numberOfRequests)

    return [
        "users": [
            [
                "id": 123,
                "username": "materik"
            ],
            [
                "id": 124,
                "username": "leo"
            ]
        ]
    ]
}
```

### Failure

```swift
Stubborn.add(url: ".*/users", error: Stubborn.Error(400, "Something went wrong"))
```

### Delayed

Wait a second before responding

```swift
1 ⏱ Stubborn.add(url: ".*/users", dictionary: ["success": true])
```

### From JSON file

```swift
Stubborn.add(url: ".*/users", resource: "MyResponse")
```

### Handle unhandled requests

```swift
Stubborn.unhandledRequest { request in
    print(request.method)
    print(request.url)
    print(request.body)
    print(request.headers)
    print(request.queryString)
}
```

### Reset

```swift
Stubborn.reset()
```

## Example

```swift
Stubborn.add(url: ".*/users") { request in
    return [
        "page": request.queryString["page"],
    ]
}

Alamofire.request("http://test.com/users?page=1").responseJSON {
    switch $0.result {
        case .success(let value):
            guard let data = value as? [AnyHashable: Any] else {
                return
            }
            print(value["page"]) // 1
        default:
        break
    }
}

Alamofire.request("http://test.com/users?page=2").responseJSON {
    switch $0.result {
        case .success(let value):
            guard let data = value as? [AnyHashable: Any] else {
                return
            }
            print(value["page"]) // 2
        default:
        break
    }
}
```

