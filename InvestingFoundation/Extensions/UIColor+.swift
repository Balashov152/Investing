//
//  UIColor+Ex.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import SwiftUI
import UIKit

public extension Color {
    static func currency(value: Double) -> Color {
        if value == .zero { return .gray }
        return value > 0 ? .green : .red
    }

    static var white: Color {
        Color(UIColor { collection -> UIColor in
            switch collection.userInterfaceStyle {
            case .light, .unspecified:
                return .white
            case .dark:
                return UIColor(white: 0.13, alpha: 1)
            @unknown default:
                return .white
            }
        })
    }

    static var appBlack: Color {
        Color(UIColor { collection -> UIColor in
            switch collection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(white: 0.13, alpha: 1)
            case .dark:
                return UIColor(white: 0.87, alpha: 1)
            @unknown default:
                return UIColor(white: 0.13, alpha: 1)
            }
        })
    }
    
    static var appWhite: Color {
        Color(UIColor { collection -> UIColor in
            switch collection.userInterfaceStyle {
            case .light, .unspecified:
                return .white
            case .dark:
                return .black
            @unknown default:
                return .black
            }
        })
    }

    static var litleGray: Color {
        Color(UIColor { collection -> UIColor in
            switch collection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(white: 0.93, alpha: 1)
            case .dark:
                return UIColor(white: 0.07, alpha: 1)
            @unknown default:
                return UIColor(white: 0.93, alpha: 1)
            }
        })
    }

    static var gray27: Color {
        Color(UIColor { collection -> UIColor in
            switch collection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(white: 0.27, alpha: 1)
            case .dark:
                return UIColor(white: 0.73, alpha: 1)
            @unknown default:
                return UIColor(white: 0.73, alpha: 1)
            }
        })
    }

    static var gray34: Color {
        Color(UIColor { collection -> UIColor in
            switch collection.userInterfaceStyle {
            case .light, .unspecified:
                return UIColor(white: 0.34, alpha: 1)
            case .dark:
                return UIColor(white: 0.66, alpha: 1)
            @unknown default:
                return UIColor(white: 0.66, alpha: 1)
            }
        })
    }
}
