![](logo.png)

[![](https://img.shields.io/badge/contact-@thematerik-blue.svg?style=flat-square)](http://twitter.com/thematerik)
[![](https://img.shields.io/cocoapods/v/Stubborn.svg?style=flat-square)](https://cocoapods.org/pods/Stubborn)
[![](https://img.shields.io/travis/materik/stubborn.svg?style=flat-square)](https://travis-ci.org/materik/stubborn)
![](https://img.shields.io/cocoapods/p/Stubborn.svg?style=flat-square)
![](https://img.shields.io/cocoapods/l/Stubborn.svg?style=flat-square)

Simple HTTP mocking framework.

# Install

```bash
pod 'Stubborn'
```

# Usage

```swift
Stubborn.shared.add(url: ".*/users") { request in
    print(request.url)
    print(request.method)
    print(request.data)
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

