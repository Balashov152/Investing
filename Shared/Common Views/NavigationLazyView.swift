//
//  NavigationLazyView.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import SwiftUI

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}
