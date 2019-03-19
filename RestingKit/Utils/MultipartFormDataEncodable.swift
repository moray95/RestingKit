//
//  MultipartEncodable.swift
//  RestingKit
//
//  Created by Moray on 2/23/19.
//

import Alamofire
import Foundation

public protocol MultipartFormDataEncodable {
    func encode(into formData: MultipartFormData, with encoder: JSONEncoder) throws
}

public protocol KeyedMultipartFormDataEncodable {
    func encode(into formData: MultipartFormData, withKey key: String, withEncoder encoder: JSONEncoder) throws
}

extension Int: KeyedMultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, withKey key: String, withEncoder encoder: JSONEncoder) throws {
        formData.append(try encoder.encode(self), withName: key)
    }
}

extension Float: KeyedMultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, withKey key: String, withEncoder encoder: JSONEncoder) throws {
        formData.append(try encoder.encode(self), withName: key)
    }
}

extension Double: KeyedMultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, withKey key: String, withEncoder encoder: JSONEncoder) throws {
        formData.append(try encoder.encode(self), withName: key)
    }
}

extension String: KeyedMultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, withKey key: String, withEncoder encoder: JSONEncoder) throws {
        formData.append(try encoder.encode(self), withName: key)
    }
}

extension Array: KeyedMultipartFormDataEncodable where Element: KeyedMultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, withKey key: String, withEncoder encoder: JSONEncoder) throws {
        try forEach {
            try $0.encode(into: formData, withKey: "\(key)[]", withEncoder: encoder)
        }
    }
}

extension Array: MultipartFormDataEncodable where Element: MultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, with encoder: JSONEncoder) throws {
        try forEach {
            try $0.encode(into: formData, with: encoder)
        }
    }
}

extension Dictionary: MultipartFormDataEncodable where Key == String, Value: KeyedMultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, with encoder: JSONEncoder) throws {
        try forEach { arg in
            let (key, value) = arg
            try value.encode(into: formData, withKey: key, withEncoder: encoder)
        }
    }
}

extension Dictionary: KeyedMultipartFormDataEncodable where Key == String, Value: KeyedMultipartFormDataEncodable {
    public func encode(into formData: MultipartFormData, withKey key: String, withEncoder encoder: JSONEncoder) throws {
        try forEach { arg in
            let (subkey, value) = arg
            try value.encode(into: formData, withKey: "\(key)[\(subkey)]", withEncoder: encoder)
        }
    }
}
