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

- Swift 5.0+

## Installation

RestingKit is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod 'RestingKit'
```

## Example project

An example project is included within the repositry. To run it, first execute `pod install`, then open `RestingKit.xcworkspace`. If you want to test file uploads with the example app, go into the `image_server` directory and run `php -S 0.0.0.0:9000 -c .`, which will start a dummy server for your uploads. The uploads will be stored in the `uploads` directory.

## Usage

### Basic example

1. Create a `RestingClient`

```swift
import RestingKit

let restingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com")
```

`RestingClient` is the core class within RestingKit that does the heavy lifting by executing the requests. It is configured to use a single base URL, so if you need to access multiple APIs, you'll need to create multiple clients.

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

   let createPostEndpoint = Endpoint<PostCreateModel, PostModel>(.post,
                                                                 "/posts",
                                                                 encoding: .json)
   ```

   An `Endpoint` is defined by the models of the request and response, the path (relative to the `RestingClient`'s `baseUrl`), the HTTP method to use and the encoding. If the request doesn't expect any content or doesn't return anything, you can use the special `Nothing` class. Ideally, we would use `Void`, but it is not possible to make it `Encodable` or `Decodable`.

3. Create the request and make the actual call

   ```swift
   let postCreateModel = PostCreateModel(userId: 1,
                                         title: "Hello world",
                                         body: "Some awesome message")
   let request = RestingRequest(endpoint createPostEndpoint,
                                body: postCreateModel)
   restingClient.perform(request).done { response in
        print("Headers: \(response.headers)")
        let post = response.body
        print("Created post with id: \(post.id)")
   }.catch { error in
        print("An error occurred: \(error)")
   }
   ```

   The promise will fail when the server responds with an HTTP status >299, so you don't have to handle this case.

   And that's it!

### Handling responses with no content

If a request might provide a response that might be empty, you can create an `Endpoint` with an optional response type. That way, if the response is empty, `nil` will be returned.

```swift
let createPostEndpoint = Endpoint<PostCreateModel, PostModel?>(.post,
                                                               "/posts",
                                                               encoding: .json)
let postCreateModel = PostCreateModel(userId: 1,
                                      title: "Hello world",
                                      body: "Some awesome message")
let request = RestingRequest(endpoint createPostEndpoint,
                             body: postCreateModel)
restingClient.perform(request).done { response in
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

**Note:** For this feature to work, the response needs to be truely empty (ie. a content-length of 0). An empty JSON object will produce a decoding error.

### Path variables

The provided `RestingRequestConverter` allows templating in paths by using [Mustache.swift](https://github.com/groue/GRMustache.swift).

```swift
let getPostEndpoint = Endpoint<Nothing, PostModel>(.get,
                                                   "/posts/{{post_id}}",
                                                   encoding: .query)
let request = RestingRequest(endpoint: getPostEndpoint,
                             body: Nothing(),
                             pathVariables: ["post_id": 1])

restingClient.perform(request).done { response in
    print("Got post: \(response.body)")
}.catch { error in
    print("An error occurred: \(error)")
}
```

### Multipart form data & file upload

It is possible to perform a multipart form data request with RestingKit. The only thing to make the request is to set the `Endpoint`'s encoding to `.multipartFormData`:

```swift
let multipartEndpoint = Endpoint<MyModel, Nothing>(.post,
                                                   "/some_resource",
                                                   encoding: .multipartFormData)
```

Now, each request using this endpoint will be encoded as `multipart/form-data`.
Uploading files is also that easy. You can use the provided `MultipartFile` class within your models, and magically, the file will be uploaded.

```swift
class ImageUploadModel: Encodable {
    let file: MultipartFile
    init(imageURL: URL) {
        self.file = MultipartFile(url: imageURL)
    }
}

let request = RestingRequest(endpoint: multipartEndpoint,
                             body: ImageUploadModel(url: imageUrl))
restingClient.upload(request).promise.done { _ in
    print("Success!")
}.catch {
    print("Error: \($0)")
}
```

**Note:** You should use `upload` methods on the `RestingClient` instead of `perform` when dealing with files and large amounts of data. `perform` will load the whole request body into memory,
while `upload` will store it into a temporary file and stream it without loading into memory.

The encoding is handled by the `MultipartFormDataEncoder`, which provides an interface and configuration options similar to `JSONEncoder`. You can customize the `MultipartFormDataEncoder`
used by the `RestingRequestConverter`:

```swift
let formDataEncoder = MultipartFormDataEncoder()
formDataEncoder.keyEncodingStrategy = .convertToSnakeCase
formDataEncoder.dateEncodingStrategy = .secondsSince1970
formDataEncoder.dataEncodingStrategy = .raw
let converter = RestingRequestConverter(multipartFormDataEncoder: formDataEncoder)
```

### Progress handlers

`RestingClient`'s `upload` methods returns a `ProgressablePromise`, which acts like classic promisses but also
accept a progress handlers.

```swift
restingClient.upload(request).progress { progress in
    print("Upload \(progress.fractionCompleted * 100)% completed")
}.done { response in
    print("Uploaded completed with response: \(response)")
}.catch { error in
    print("An error occurred")
}
```

### Interceptors

Interceptors allow to intercept any request and response, and modify it before the request is sent or the response processed. Some basic usages of interceptors include:

- Logging requests and responses
- Injecting headers
- Retrying failed requests

To use interceptors, you will need to implement the `RestingInterceptor` protocol and provide your interceptor to your `RestingClient`.

```swift
class LogInterceptor: RestingInterceptor {
    func intercept(request: HTTPRequest, execution: Execution)
        -> ProgressablePromise<HTTPDataResponse> {
        print("sending request \(request)")
        return execution(request).get { response in
            print("got response \(response)")
        }
    }
}

class DeviceIdInjector: RestingInterceptor {
    func intercept(request: HTTPRequest, execution: Execution) -> ProgressablePromise<HTTPDataResponse> {
        var urlRequest = request.urlRequest
        urlRequest.setValue(UIDevice.current.identifierForVendor?.uuidString,
                           forHTTPHeaderField: "device-id")
        let request = BasicHTTPRequest(urlRequest: urlRequest, fileUrl: request.fileUrl)
        return execution(request)
    }
}

let restingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                  decoder: decoder,
                                  requestConverter: requestConverter,
                                  interceptors: [DeviceIdInjector(), LogInterceptor()])
```

The `RestingClient` will pass the request to the interceptors in the provided order, while the response is passed in the reverse order. Therefore, it is important to place `LogInterceptor` at the end of the array (otherwise, it will not be able to log the `device-id` header added by `DeviceIdInjector`).

RestingKit provides an interceptor for logging requests and responses: `RequestResponseLoggingInterceptor`.

**Important**: It is required for each interceptor to call the `execution` parameter, as it is what will run the next interceptors and finally the request. Unless, of course, you do not want to run additional interceptors or send the request.

### Using a custom HTTPClient

`HTTPClient`s are the classes that performs the requests. They take an `HTTPRequest` and return a `(Progressable)Promise<HTTPDataResponse>` without doing anything. `AlamofireClient` is the provided implementation that uses Alamofire to perform the requests and the default client used by `RestingClient`. You can configure a `RestingClient` to use your own implementation:

```swift
class MyHTTPClient: HTTPClient {
    public func perform(urlRequest: URLRequest) -> Promise<HTTPDataResponse> {
        // Handle classic request
    }
    func upload(request: HTTPRequest) -> ProgressablePromise<HTTPDataResponse> {
        // Handle uplaod request, with a progress handler
    }
}

let restingClient = RestingClient(baseUrl: "https://jsonplaceholder.typicode.com",
                                  httpClient: MyHTTPClient())
```

## Work in progress

As RestingKit is still new and in development, there are some missing features that needs implementation:

- File downloads
- Any other feature you might request!

Additionally, there might be some api-breaking changes until the project reaches full maturity.

## Contributing

If you need help with getting started or have a feature request, just open up an issue. Pull requests are also welcome for bug fixes and new features.

## Author

Moray Baruh

## License

RestingKit is available under the MIT license. See the LICENSE file for more info.
