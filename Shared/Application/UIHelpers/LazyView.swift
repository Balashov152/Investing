//
//  LazyView.swift
//  Investing
//
//  Created by Sergey Balashov on 04.04.2022.
//

import SwiftUI

struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
