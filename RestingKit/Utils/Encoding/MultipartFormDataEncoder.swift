//
//  MultipartFormDataEncoder.swift
//  RestingKit
//
//  Created by Moray on 2/23/19.
//

// swiftlint:disable file_length

import Alamofire
import Foundation

/// An object that encodes `Encodable` objects into `MultipartFormData`.
public class MultipartFormDataEncoder {
    /// Defines available strategies to use when encoding key names.
    public enum KeyEncodingStrategy {
        /// Converts keys into snake_case.
        case convertToSnakeCase
        /// Uses keys as they are defined, without modifying them.
        case useDefaultKeys
        /// Uses a custom coding strategy defined by the closed provided.
        case custom(([CodingKey]) -> CodingKey)
    }

    /// Defines available strategies when encoding `Date` instances.
    public enum DateEncodingStrategy {
        /// Encodes by `encode(to:)` on the date instance.
        case deferredToDate
        /// Encodes an integer with the number of seconds since midnight UTC on January 1, 1970.
        case secondsSince1970
        /// Encodes an integer with the number of milliseconds since midnight UTC on January 1, 1970.
        case millisecondsSince1970
        /// Encodes the date with the provided `ISO8601DateFormatter`.
        case iso8601(ISO8601DateFormatter)
        /// Encodes the date with the provided `DateFormatter`.
        case formatted(DateFormatter)
        /// Delegates the encoding to the closure provided.
        case custom((Date, Encoder) throws -> Void)
    }

    /// Defines available strategies when encoding `Data` instances.
    public enum DataEncodingStrategy {
        /// Encode the data as is.
        case raw
        /// Encodes the data using Base 64.
        case base64
        /// Delegates the encoding to the closure provided.
        case custom((Data, Encoder) throws -> Void)
    }

    struct Options {
        var keyEncodingStrategy: KeyEncodingStrategy
        var dateEncodingStrategy: DateEncodingStrategy
        var dataEncodingStrategy: DataEncodingStrategy
    }

    var options: Options

    /// The strategy to use for encoding key names. Defaults to `KeyEncodingStrategy.useDefaultKeys`.
    public var keyEncodingStrategy: KeyEncodingStrategy {
        get { return options.keyEncodingStrategy }
        set { options.keyEncodingStrategy = newValue }
    }

    /// The strategy to use for encoding `Date` instances. Defaults to `DateEncodingStrategy.deferredToDate`.
    public var dateEncodingStrategy: DateEncodingStrategy {
        get { return options.dateEncodingStrategy }
        set { options.dateEncodingStrategy = newValue }
    }

    /// The strategy to use for encoding `Data` instances. Defaults to `DataEncodingStrategy.raw`.
    public var dataEncodingStrategy: DataEncodingStrategy {
        get { return options.dataEncodingStrategy }
        set { options.dataEncodingStrategy = newValue }
    }

    /// Creates a new `MultipartFormDataEncoder`.
    public init() {
        self.options = Options(keyEncodingStrategy: .useDefaultKeys,
                               dateEncodingStrategy: .deferredToDate,
                               dataEncodingStrategy: .raw)
    }

    ///
    /// Encodes an `Encodable` into a `MultipartFormData`.
    ///
    /// - parameter value: The object to encode.
    ///
    /// - returns: A `MultipartFormData` that represents `value`.
    ///
    /// - throws: `EncodingError.invalidValue(_:,_:)` if the object can't be encoded
    ///           for some reason.
    ///
    public func encode<T: Encodable>(_ value: T) throws -> MultipartFormData {
        let encoder = _MultipartFormDataEncoder(options: options, codingPath: [])
        var container = encoder.singleValueContainer()
        try container.encode(value)
        let formData = MultipartFormData()
        switch encoder.node {
        case nil:
            fatalError("No value encoded")
        case .some(.object(let object)):
            object.forEach {
                let (key, value) = $0
                write(value, into: formData, forPath: [RestingCodingKey(stringValue: key)])
            }
        case .some(let node):
            let description = "Expected to find a dictionary as top-level object, found \(node) instead"
            let context = EncodingError.Context(codingPath: encoder.codingPath,
                                                debugDescription: description)
            throw EncodingError.invalidValue(value, context)
        }

        return formData
    }

    private func write(_ node: MultipartNode, into formData: MultipartFormData, forPath path: [CodingKey]) {
        switch node {
        case .data(let data):
            formData.append(data, withName: fieldName(for: path))
        case .array(let array):
            array.enumerated().forEach { index, node in
                write(node, into: formData, forPath: path + [RestingCodingKey(intValue: index)])
            }
        case .object(let object):
            object.forEach {
                let (innerKey, node) = $0
                write(node, into: formData, forPath: path + [RestingCodingKey(stringValue: innerKey)])
            }
        case .file(let file):
            formData.append(file.url, withName: fieldName(for: path))
        case .null:
            formData.append("null".data(using: .utf8)!, withName: fieldName(for: path))
        }
    }

    private func fieldName(for path: [CodingKey]) -> String {
        if path.isEmpty {
            fatalError("No path provided")
        }

        if path.count == 1 {
            switch options.keyEncodingStrategy {
            case .useDefaultKeys:
                return path.first!.stringValue
            case.convertToSnakeCase:
                return path.first!.stringValue.convertToSnakeCase()
            case .custom(let converter):
                return converter(path).stringValue
            }
        }

        let mapper: ([CodingKey]) -> String
        switch options.keyEncodingStrategy {
        case .useDefaultKeys:
            mapper = { $0.reduce("") { carry, key in "\(carry)[\(key.stringValue)]" } }
        case.convertToSnakeCase:
            mapper = { $0.reduce("") { carry, key in "\(carry)[\(key.stringValue.convertToSnakeCase())]" } }
        case .custom(let converter):
            mapper = { converter($0).stringValue }
        }

        return mapper(path)
    }
}

private class _MultipartFormDataEncoder: Encoder {
    fileprivate var codingPath: [CodingKey]
    fileprivate var userInfo: [CodingUserInfoKey: Any] = [:]

    fileprivate var node: MultipartNode?

    fileprivate var object: [String: MultipartNode] {
        get { return node?.object ?? [:] }
        set { node?.object = newValue }
    }

    fileprivate var array: [MultipartNode] {
        get { return node?.array ?? [] }
        set { node?.array = newValue }
    }

    private var canEncodeNewValue: Bool { return node == nil }
    fileprivate let options: MultipartFormDataEncoder.Options

    fileprivate init(options: MultipartFormDataEncoder.Options, codingPath: [CodingKey]) {
        self.options = options
        self.codingPath = codingPath
    }

    fileprivate func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        switch node {
        case .some(.object):
            break
        case .some:
            preconditionFailure(
                "Attempt to push new keyed encoding container when already previously encoded at this path."
            )
        case .none:
            node = .object([:])
        }
        return .init(_KeyedEncodingContainer<Key>(referencing: self))
    }

    fileprivate func unkeyedContainer() -> UnkeyedEncodingContainer {
        switch node {
        case .some(.array):
            break
        case .some:
            preconditionFailure(
                "Attempt to push new keyed encoding container when already previously encoded at this path."
            )
        case .none:
            node = .array([])
        }
        return _UnkeyedEncodingContainer(referencing: self)
    }

    fileprivate func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }

    fileprivate func encoder(for key: CodingKey) -> _ReferencingEncoder {
        return .init(referencing: self, key: key)
    }

    fileprivate func encoder(at index: Int) -> _ReferencingEncoder {
        return .init(referencing: self, at: index)
    }
}

private class _ReferencingEncoder: _MultipartFormDataEncoder {
    private enum Reference {
        case object(String)
        case array(Int)
    }

    private let encoder: _MultipartFormDataEncoder
    private let reference: Reference

    fileprivate init(referencing encoder: _MultipartFormDataEncoder, key: CodingKey) {
        self.encoder = encoder
        reference = .object(key.stringValue)
        super.init(options: encoder.options, codingPath: encoder.codingPath + [key])
    }

    fileprivate init(referencing encoder: _MultipartFormDataEncoder, at index: Int) {
        self.encoder = encoder
        reference = .array(index)
        super.init(options: encoder.options, codingPath: encoder.codingPath + [RestingCodingKey(intValue: index)])
    }

    deinit {
        guard let node = node else { return }
        switch reference {
        case .object(let key):
            encoder.node![key] = node
        case .array(let index):
            encoder.node![index] = node
        }
    }
}

extension _MultipartFormDataEncoder: SingleValueEncodingContainer {
    func encodeNil() throws {
        assertCanEncodeNewValue()
        node = .null
    }

    func encode<T>(_ value: T) throws where T: Encodable {
        assertCanEncodeNewValue()
        if let file = value as? MultipartFile {
            try encode(file)
            return
        }
        if let date = value as? Date {
            try encode(date)
            return
        }
        if let data = value as? Data {
            try encode(data)
            return
        }
        try value.encode(to: self)
    }

    func encode(_ file: MultipartFile) throws {
        assertCanEncodeNewValue()
        node = .file(file)
    }

    func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        self.node = .data(value.data(using: .utf8)!)
    }

    func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        self.node = .data("\(value)".data(using: .utf8)!)
    }

    func encode(_ value: Date) throws {
        assertCanEncodeNewValue()
        switch options.dateEncodingStrategy {
        case .deferredToDate:
            try value.encode(to: self)
        case .secondsSince1970:
            try encode(value.timeIntervalSince1970)
        case .millisecondsSince1970:
            try encode(value.timeIntervalSince1970 * 1000.0)
        case .iso8601(let formatter):
            try encode(formatter.string(from: value))
        case .formatted(let formatter):
            try encode(formatter.string(from: value))
        case .custom(let callback):
            try callback(value, self)
        }
    }

    func encode(_ value: Data) throws {
        assertCanEncodeNewValue()
        switch options.dataEncodingStrategy {
        case .raw:
            self.node = .data(value)
        case .base64:
            self.node = .data(value.base64EncodedData())
        case .custom(let callback):
            try callback(value, self)
        }
    }

    private func assertCanEncodeNewValue() {
        precondition(node == nil,
                     "Attempt to encode value through single value container when previously value already encoded.")
    }
}

private struct _KeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    private let encoder: _MultipartFormDataEncoder
    fileprivate var codingPath: [CodingKey] { return encoder.codingPath }

    fileprivate init(referencing encoder: _MultipartFormDataEncoder) {
        self.encoder = encoder
    }

    fileprivate func encodeNil(forKey key: Key) throws {
        encoder.node?[key.stringValue] = .null
    }

    fileprivate func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        if let file = value as? MultipartFile {
            try encoder(for: key).encode(file)
            return
        }
        try encoder(for: key).encode(value)
    }

    fileprivate func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type,
                                                forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        return encoder(for: key).container(keyedBy: type)
    }

    fileprivate func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        return encoder(for: key).unkeyedContainer()
    }

    fileprivate func superEncoder() -> Encoder {
        return encoder(for: RestingCodingKey(stringValue: "super"))
    }

    fileprivate func superEncoder(forKey key: Key) -> Encoder {
        return encoder(for: key)
    }

    private func encoder(for key: CodingKey) -> _ReferencingEncoder {
        return encoder.encoder(for: key)
    }
}

private struct _UnkeyedEncodingContainer: UnkeyedEncodingContainer {
    private let encoder: _MultipartFormDataEncoder

    fileprivate var codingPath: [CodingKey] { return encoder.codingPath }
    fileprivate var count: Int { return encoder.array.count }

    fileprivate init(referencing encoder: _MultipartFormDataEncoder) {
        self.encoder = encoder
    }

    // MARK: - Swift.UnkeyedEncodingContainer Meth

    fileprivate func encodeNil() throws {
        encoder.node = .null
    }

    fileprivate func encode<T>(_ value: T) throws where T: Encodable {
        if let file = value as? MultipartFile {
            try currentEncoder.encode(file)
            return
        }
        try currentEncoder.encode(value)
    }

    fileprivate func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        return currentEncoder.container(keyedBy: type)
    }

    fileprivate func nestedUnkeyedContainer() -> UnkeyedEncodingContainer { return currentEncoder.unkeyedContainer() }
    fileprivate func superEncoder() -> Encoder { return currentEncoder }

    private var currentEncoder: _ReferencingEncoder {
        defer { encoder.array.append(.data(Data())) }
        return encoder.encoder(at: count)
    }
}
