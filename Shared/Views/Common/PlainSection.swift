//
//  PlainSection.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import SwiftUI

struct PlainSection<Header: View, Content: View>: View {
    let header: Header
    let content: () -> Content

    var body: some View {
        header
        content()
    }
}
