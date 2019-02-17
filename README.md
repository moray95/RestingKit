# RestingKit

[![CI Status](https://img.shields.io/travis/moray95/RestingKit.svg?style=flat)](https://travis-ci.org/moray95/RestingKit)
[![Version](https://img.shields.io/cocoapods/v/RestingKit.svg?style=flat)](https://cocoapods.org/pods/RestingKit)
[![License](https://img.shields.io/cocoapods/l/RestingKit.svg?style=flat)](https://cocoapods.org/pods/RestingKit)
[![Platform](https://img.shields.io/cocoapods/p/RestingKit.svg?style=flat)](https://cocoapods.org/pods/RestingKit)

## Introduction

RestingKit is a higher-level wrapper around [Alamofire](https://github.com/Alamofire/Alamofire) and [PromiseKit](https://github.com/mxcl/PromiseKit) written in Swift that allows developers to concentrate on the important stuff instead of writing boiler-plate code for their REST API.

## Features

- Configurable HTTP client (Alamofire is currently the only one provided, but you can write your own!)
- Path variable expansion powered by [GRMustache.swift](https://github.com/groue/GRMustache.swift)
- Interception (and modification) of all requests and responses

## Requirements

- iOS 10.0+

- Swift 4.2

## Installation

RestingKit is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'RestingKit'
```

## Usage

### Basic example

1. Create a `RestingClient`

```swift
import RestingKit

let encoder = JSONEncoder()
let decoder = JSONDecoder()
let requestConverter = RestingRequestConverter(jsonEncoder: encoder, jsonDecoder: decoder)
let restingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                   decoder: decoder,
                                   requestConverter: requestConverter)
```

- `RestingClient` is the core class within RestingKit that does the heavy lifting by executing the requests. It is configured to use a single base URL, so if you need to access multiple APIs, you'll need to create multiple clients.
- `RequestConverter` s transforms a `RestingRequest` to a `URLRequestConvertible`. `RestingRequestConverter` is the provided implementation that supports path templating.

2. Define your models and endpoints

   ```swift
   struct PostCreateModel: Codable {
       let userId: Int
       let title: String
       let body: String

       init(userId: Int, title: String, body: String) {
           self.userId = userId
           self.title = title
           self.body = body
       }
   }

   struct PostModel: Codable {
       let id: Int
       let userId: Int
       let title: String
       let body: String
   }

   let createPostEndpoint = Endpoint<PostCreateModel, PostModel>(path: "/posts",
                                                                 method: .post,
                                                                 encoding: .json)
   ```

An `Endpoint` is defined by the models of the request and response, the path (relative to the `RestingClient`'s `baseUrl`, the HTTP method to use and the encoding. If the request doesn't expect any content or doesn't return anything, you can use the special `Nothing` class. Ideally, we would use `Void`, but it is not possible to make it `Encodable` or `Decodable`.

3. Create the request and make the actual call

   ```swift
   let postCreateModel = PostCreateModel(userId: 1,
                                         title: "Hello world",
                                         body: "Some awesome message")
   let request = RestingRequest(endpoint createPostEndpoint,
                                body: postCreateModel)
   restingClient.done { response in
        print("Headers: \(response.headers)")
           let post = response.body
           print("Created post with id: \(post.id)")
   }.catch { error in
           print("An error occurred: \(error)")
   }
   ```

The promise will fail when the request encountered networking issues or the server responded with an HTTP status >299.

And that's it!

### Handling responses with no content

If a request might provide a response that might be empty, you can create an `Endpoint` with an optional response type. That way, if the response is empty, `nil` will be returned.

```swift
let createPostEndpoint = Endpoint<PostCreateModel, PostModel?>(path: "/posts",
                                                               method: .post,
                                                               encoding: .json)
restingClient.done { response in
    print("Headers: \(response.headers)")
    if let post = response.body {
        print("Created post with id: \(post.id)")
    } else {
        print("Empty body")
    }
}.catch { error in
    print("An error occurred: \(error)")
}
```

**Note:** For this feature to work, the response needs to be truely empty. An empty JSON object will produce a decoding error.

### Path variables

The provided `RestingRequestConverter` allows templating in paths by using [Mustache.swift](https://github.com/groue/GRMustache.swift).

```swift
let getPostEndpoint = Endpoint<Nothing, PostModel>(path: "/posts/{{post_id}}",
                                                   method: .get,
                                                   encoding: .query)
let request = RestingRequest(endpoint: Endpoints.Posts.get,
                             body: Nothing(),
                             pathVariables: ["post_id": 1])

restingClient.perform(request).done { response in
    print("Got post: \(response.body)")
}.catch { error in
    print("An error occurred: \(error)")
}
```

### Interceptors

Interceptors allow to intercept any request and response, and modify it before the request is sent or the response processed. Some basic usages of interceptors include:

- Logging requests and responses
- Injecting headers

To use interceptors, you will need to implement the `RestingInterceptor` protocol and provide your interceptor to your `RestingClient`.

```swift
class LogInterceptor: RestingInterceptor {
    func intercept(request: URLRequest,
                   execution: (URLRequest) -> Promise<HTTPDataResponse>) -> Promise<HTTPDataResponse>
    print("sending request \(request)")
    return execution.get { response in
        print("got response \(response)")
    }
}

class DeviceIdInjector: RestingInterceptor {
    func intercept(request: URLRequest,
                   execution: (URLRequest) -> Promise<HTTPDataResponse>)
        -> Promise<HTTPDataResponse> {
        var request = request
        request.setValue(UIDevice.current.identifierForVendor?.uuidString,
                         forHTTPHeaderField: "device-id")
        return execution(request)
    }
}

let restingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                  decoder: decoder,
                                  requestConverter: requestConverter,
                                  interceptors: [DeviceIdInjector(), LogInterceptor()])
```

The `RestingClient` will pass the request to the interceptors in the provided order, while the response is passed in the reverse order. Therefore, it is important to place `LogInterceptor` at the end of the array (otherwise, it will not be able to log the `device-id` header added by `DeviceIdInjector`).

RestingKit provides an interceptor for logging requests and responses: `RequestResponseLoggingInterceptor`

**Important**: It is required for each interceptor to call the `execution` parameter, as it is what will run the next interceptors and finally the request. Unless, of course, you do not want to run additional interceptors or send the request.

### Using a custom HTTPClient

`HTTPClient` s are the class that performs the requests, takes a `URLRequest` and returns a `Promise<HTTPDataResponse>` without doing anything. `AlamofireClient` is the provided implementation that uses Alamofire to perform the requests and the default client used by `RestingClient`. You can configure a `RestingClient` to use your own implementation:

```swift
class MyHTTPClient: HTTPClient {
    public func perform(urlRequest: URLRequest) -> Promise<HTTPDataResponse> {
        // Do your stuff here
    }
}

let restingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                  decoder: decoder,
                                  httpClient: MyHTTPClient(),
                                  requestConverter: requestConverter)
```



## Work in progress

As RestingKİt is still new and in development, there are some missing features that needs implementation:

- File uploads and downloads
- Multipart requests and responses
- Progress callbacks
- Any other feature you might request!

Additionally, there might be some api-breaking changes until the project reaches full-maturity.

## Contributing

If you need help with getting started or have a feature request, just open up an issue. Pull requests are also welcome for bug fixes and new features.

## Author

Moray Baruh

## License

RestingKit is available under the MIT license. See the LICENSE file for more info.
