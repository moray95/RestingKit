//
//  HTTPResponseType.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

public protocol HTTPResponseType {
    associatedtype BodyType

    var body: BodyType { get }
    var headers: [String: String] { get }
}
