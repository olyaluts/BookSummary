//
//  Emptyable.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation

protocol Emptyable {
    static var emptyValue: Self { get }
}

extension Optional where Wrapped: Emptyable {
    func orEmpty() -> Wrapped {
        switch self {
        case .none:
            return Wrapped.emptyValue
        case let .some(value):
            return value
        }
    }
}

extension String: Emptyable {
    static var emptyValue: String { "" }
}

extension Bool: Emptyable {
    static var emptyValue: Bool { false }
}

extension UInt: Emptyable {
    static var emptyValue: UInt { 0 }
}

extension Int: Emptyable {
    static var emptyValue: Int { 0 }
}

extension Float: Emptyable {
    static var emptyValue: Float { 0 }
}
