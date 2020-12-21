//
//  StringConvertible.swift
//  SellFashion
//
//  Created by Sergey Balashov on 17.02.2020.
//  Copyright © 2020 Sellfashion. All rights reserved.
//

import Foundation

public protocol StringConvertible {
    var string: String { get }
}

extension Int: StringConvertible {
    public var string: String { "\(self)" }
}

extension String: StringConvertible {
    public var string: String { self }
}

extension Optional: StringConvertible where Wrapped == String {
    public var string: String { self ?? UUID().uuidString }
}

extension Date: StringConvertible {
    public var string: String { "\(hashValue)" }
}


extension Optional where Wrapped == String {
    var orEmpty: String {
        self ?? ""
    }
}

extension Double {
    func string(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
