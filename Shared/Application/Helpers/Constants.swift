//
//  Constants.swift
//  Investing
//
//  Created by Sergey Balashov on 15.04.2021.
//

import CoreGraphics

enum Constants {
    enum FIGI: String {
        var value: RawValue { rawValue }

        case USD = "BBG0013HGFT4"
        case EUR = "BBG0013HJJ31"
    }

    enum Paddings {
        static let m: CGFloat = 16
    }
}
