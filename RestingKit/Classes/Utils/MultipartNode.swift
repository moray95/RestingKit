//
//  MultipartNode.swift
//  RestingKit
//
//  Created by Moray on 2/24/19.
//

import Foundation

enum MultipartNode {
    case object([String: MultipartNode])
    case array([MultipartNode])
    case file(MultipartFile)
    case data(Data)
    case null

    var object: [String: MultipartNode] {
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

    var array: [MultipartNode] {
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

    subscript(index: Int) -> MultipartNode {
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

    subscript(index: String) -> MultipartNode {
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
