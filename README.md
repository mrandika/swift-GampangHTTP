# GampangHTTP
[![Build and Test GampangHTTP](https://github.com/mrandika/swift-GampangHTTP/actions/workflows/build-test.yml/badge.svg?branch=main)](https://github.com/mrandika/swift-GampangHTTP/actions/workflows/build-test.yml)


Dead-simple HTTP Networking in Swift using URLSession.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Advanced Configuration](#advanced-configuration)
- [Request Construction](#request-construction)
  - [Creating a Basic Request](#creating-a-basic-request)
  - [Setting HTTP Method](#setting-http-method)
  - [Adding Headers](#adding-headers)
  - [Adding Query Items](#adding-query-items)
  - [Setting Request Body](#setting-request-body)
  - [Combining Multiple Components](#combining-multiple-components)
  - [Using GampangURLRequest with GampangHTTP](#using-gampangurlrequest-with-gampanghttp)
- [Features](#features)
  - [Caching](#caching)
  - [Certificate Pinning](#certificate-pinning)
  - [Retry Policy](#retry-policy)
  - [Logging](#logging)

## Installation

GampangHTTP can be installed using Swift Package Manager. Add it to your project's `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/mrandika/swift-GampangHTTP.git", from: "x.x.x")
]
```

Then, add GampangHTTP to your target's dependencies:
```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["GampangHTTP"]),
]
```

## Usage
### Basic Usage
1. Import GampangHTTP in your Swift file:
```swift
import GampangHTTP
```
2. Create an instance of GampangHTTP:
```swift
let http = GampangHTTP()
```
4. Make a request:
```swift
struct HttpBin: Decodable {
    let origin: String
    let url: String
}

do {
    let response: HttpBin = try await http.request(
        with: URLRequest(url: URL(string: "https://httpbin.org/get")!),
        of: HttpBin.self
    )

    print("Response: \(response.origin) \(response.url)")
} catch {
    print("Error: \(error)")
}
```

### Advanced Configuration
You can customize GampangHTTP with various options:
```swift
let customHTTP = GampangHTTP(
    cache: URLCache(memoryCapacity: 20_000_000, diskCapacity: 200_000_000, diskPath: "custom_cache"),
    logger: CustomLogger(),
    retryPolicy: CustomRetryPolicy(),
    pinnedCertificates: [/* Your pinned certificates */]
)
```

## Request Construction
GampangHTTP uses `GampangURLRequest` to construct HTTP requests. This struct provides a convenient way to set various components of a request.

### Creating a Basic Request
```swift
let request = GampangURLRequest(url: "https://api.example.com/users", method: .get)
```

### Setting HTTP Method
```swift
let postRequest = GampangURLRequest(url: "https://api.example.com/users", method: .post)
```
Available HTTP methods:
1. `.post`
2. `.get`
3. `.put`
4. `.delete`
5. `.patch`
6. `.head`
7. `.options`
8. `.trace`
9. `.connect`

> Reference: [HTTP request methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)

### Adding Headers
```swift
let request = GampangURLRequest(
    url: "https://api.example.com/users",
    method: .get,
    headers: [
        (.contentType, "application/json"),
        (.authorization, "Bearer your-token-here")
    ]
)
```
Available header fields:
1. `.contentType`
2. `.authorization`
3. `.accept`

> 💡 More header fields and custom are coming soon.

### Adding Query Items
```swift
let request = GampangURLRequest(
    url: "https://api.example.com/search",
    method: .get,
    queryItems: [
        URLQueryItem(name: "q", value: "swift"),
        URLQueryItem(name: "page", value: "1")
    ]
)
```

### Setting Request Body
For requests with a JSON body:
```swift
let body: [String: Any] = ["name": "John Doe", "email": "john@example.com"]
let request = GampangURLRequest(
    url: "https://api.example.com/users",
    method: .post,
    body: body
)
```

For requests with raw data:

Alternatively, you can use [Encodable](https://developer.apple.com/documentation/swift/encodable) protocol and convert it to data representation
```swift
let data = "Raw data".data(using: .utf8)!
let request = GampangURLRequest(
    url: "https://api.example.com/upload",
    method: .post,
    data: data
)
```

### Combining Multiple Components
You can combine all these components in a single request:
```swift
let request = GampangURLRequest(
    url: "https://api.example.com/users",
    method: .post,
    body: ["name": "John Doe", "email": "john@example.com"],
    queryItems: [URLQueryItem(name: "version", value: "v2")],
    headers: [
        (.contentType, "application/json"),
        (.authorization, "Bearer your-token-here")
    ]
)
```

### Using GampangURLRequest with GampangHTTP
Once you've constructed your request, you can use it with GampangHTTP:
```swift
let http = GampangHTTP()

do {
    let urlRequest = try request.build
    let response: APIResponse = try await http.request(with: urlRequest, of: APIResponse.self)
    print("Response: \(response)")
} catch {
    print("Error: \(error)")
}
```
> Note: The build property of GampangURLRequest converts it to a URLRequest, which can be used with GampangHTTP.

## Features
### Caching
GampangHTTP supports response caching out of the box. To disable caching:
```swift
let httpNoCache = GampangHTTP(cache: nil)
```

### Certificate Pinning
Enable certificate pinning by providing an array of pinned certificates:
```swift
let httpWithPinning = GampangHTTP(pinnedCertificates: [/* Your pinned certificates */])
```

### Retry Policy
GampangHTTP uses a default retry policy. You can provide a custom policy:
```swift
class CustomRetryPolicy: GampangRetryPolicy {
    // Implement your custom retry logic here
}

let httpWithCustomRetry = GampangHTTP(retryPolicy: CustomRetryPolicy())
```

### Logging
GampangHTTP includes a default console logger. You can provide a custom logger:
```swift
class CustomLogger: GampangLogger {
    func log(_ message: String) {
        // Implement your custom logging logic here
    }
}

let httpWithCustomLogger = GampangHTTP(logger: CustomLogger())
```
