//
//  UIColor+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import SwiftUI
import UIKit

extension UIColor {
    static var litleGray: UIColor {
        UIColor { (collection) -> UIColor in
            switch collection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(white: 0.93, alpha: 1)
            case .dark:
                return UIColor(white: 0.07, alpha: 1)
            @unknown default:
                return UIColor(white: 0.93, alpha: 1)
            }
        }
    }
}

extension Color {
    static func currency(value: Double) -> Color {
        if value == .zero { return .gray }

        return value > 0 ? .green : .red
    }
}
