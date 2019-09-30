//
//  Nothing.swift
//  RestingKit
//
//  Created by Moray on 2/16/19.
//

import Foundation

/// Represents nothing. To be used for requests that sends or expects no data.
public struct Nothing: Codable {
    /// Creates a new `Nothing`.
    public init() {}
}
