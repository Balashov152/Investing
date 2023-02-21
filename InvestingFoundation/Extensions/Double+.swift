//
//  Double+.swift
//  Investing
//
//  Created by Sergey Balashov on 14.02.2023.
//

import Foundation

public extension Double {
    var percentFormat: String {
        string(f: ".2") + "%"
    }
    
    func string(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
