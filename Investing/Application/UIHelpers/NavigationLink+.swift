//
//  NavigationLink+.swift
//  Investing
//
//  Created by Sergey Balashov on 04.04.2022.
//

import SwiftUI

extension View {
    func addNavigationLink<Destination: View>(@ViewBuilder destination: @escaping () -> Destination) -> some View {
        background(NavigationLink(destination: LazyView<Destination>(destination()), label: {
            EmptyView()
        }))
    }
}
