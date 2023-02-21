//
//  Navigation+.swift
//  Investing
//
//  Created by Sergey Balashov on 21.02.2023.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func navigationDestination<Item, V: View>(
        item: Binding<Item?>,
        @ViewBuilder destination: (Item) -> V
    ) -> some View {
        if let wrapped = item.wrappedValue {
            let isPresented = Binding<Bool> {
                item.wrappedValue != nil
            } set: { isPresented in
                if !isPresented {
                    item.wrappedValue = nil
                }
            }

            navigationDestination(isPresented: isPresented) {
                destination(wrapped)
            }
        }
    }
}
