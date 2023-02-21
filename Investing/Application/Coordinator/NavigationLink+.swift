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

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
