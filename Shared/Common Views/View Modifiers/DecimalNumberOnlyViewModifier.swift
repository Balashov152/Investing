//
//  DecimalNumberOnlyViewModifier.swift
//  Investing
//
//  Created by Sergey Balashov on 20.02.2021.
//

import Combine
import SwiftUI

public struct DecimalNumberOnlyViewModifier: ViewModifier {
    @Binding var text: String

    public init(text: Binding<String>) {
        _text = text
    }

    public func body(content: Content) -> some View {
        content
            .keyboardType(.numberPad)
            .onReceive(Just(text)) { newValue in
                let filtered = newValue.reduce("") { result, symbol -> String in
                    if symbol.isNumber {
                        return result + String(symbol)
                    }

                    if symbol == ".", !result.contains(".") {
                        return result + String(symbol)
                    }

                    return result
                }

                if filtered != newValue {
                    self.text = filtered
                }
            }
    }
}
