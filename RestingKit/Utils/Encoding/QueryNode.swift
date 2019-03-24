//
//  QueryNode.swift
//  RestingKit
//
//  Created by Moray on 3/24/19.
//

import Foundation

enum QueryNode {
    case object([String: QueryNode])
    case array([QueryNode])
    case string(String)
    case null

    var object: [String: QueryNode] {
        get {
            switch self {
            case .object(let object):
                return object
            default:
                return [:]
            }
        }
        set {
            self = .object(newValue)
        }
    }

    var array: [QueryNode] {
        get {
            switch self {
            case .array(let array):
                return array
            default:
                return []
            }
        }
        set {
            self = .array(newValue)
        }
    }

    subscript(index: Int) -> QueryNode {
        get {
            switch self {
            case .array(let array):
                return array[index]
            default:
                return .null
            }
        }
        set {
            switch self {
            case .array(var array):
                array[index] = newValue
                self = .array(array)
            default:
                return
            }
        }
    }

    subscript(index: String) -> QueryNode {
        get {
            switch self {
            case .object(let dict):
                return dict[index] ?? .null
            default:
                return .null
            }
        }
        set {
            switch self {
            case .object(var dict):
                dict[index] = newValue
                self = .object(dict)
            default:
                return
            }
        }
    }
}
