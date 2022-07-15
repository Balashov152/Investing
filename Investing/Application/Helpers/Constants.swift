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
        /// 2
        static let xxxs: CGFloat = 2
        
        /// 4
        static let xxs: CGFloat = 4

        /// 8
        static let xs: CGFloat = 8

        /// 12
        static let s: CGFloat = 12

        /// 16
        static let m: CGFloat = 16
    }
}
