//
//  CodingKey+Flatten.swift
//  RestingKit
//
//  Created by Moray on 11/16/19.
//

import Foundation

extension Array where Element == CodingKey {
    func flatten(with strategy: MultipartFormDataEncoder.KeyEncodingStrategy) -> String {
        switch strategy {
        case .useDefaultKeys:
            return flatten { $0 }
        case.convertToSnakeCase:
            return flatten { $0.convertToSnakeCase() }
        case .custom(let converter):
            return converter(self).stringValue
        }
    }

    func flatten(with strategy: QueryParameterEncoder.KeyEncodingStrategy) -> String {
        switch strategy {
        case .useDefaultKeys:
            return flatten { $0 }
        case.convertToSnakeCase:
            return flatten { $0.convertToSnakeCase() }
        case .custom(let converter):
            return converter(self).stringValue
        }
    }

    func flatten(converter: (String) -> String) -> String {
        let first = converter(self.first!.stringValue)
        return dropFirst().reduce(first) { carry, key in
            if key.intValue != nil {
                return "\(carry)[\(converter(key.stringValue))]"
            } else {
                return "\(carry)[]"
            }
        }
    }
}
