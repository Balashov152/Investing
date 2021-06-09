//
//  RowDisclosureGroup.swift
//  Investing
//
//  Created by Sergey Balashov on 27.02.2021.
//

import Foundation
import SwiftUI

struct RowDisclosureGroup<Element: Hashable, Content: View, Label: View>: View {
    let element: Element
    @State private var expanded: Set<Element> = [] {
        didSet { expandedChanged(expanded) }
    }

    var expandedChanged: (Set<Element>) -> Void = { _ in }
    let content: () -> (Content)
    let label: () -> (Label)

    func isExpanded(element: Element) -> Binding<Bool> {
        .init { () -> Bool in
            expanded.contains(element)
        } set: { _ in
            changeExpanded(element: element)
        }
    }

    func changeExpanded(element: Element) {
        if !expanded.contains(element) {
            expanded.insert(element)
        } else {
            expanded.remove(element)
        }
    }

    var body: some View {
        DisclosureGroup(isExpanded: isExpanded(element: element),
                        content: content, label: {
                            label()
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        changeExpanded(element: element)
                                    }
                                }
                        })
    }
}
