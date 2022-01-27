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

    @State private var expanded: Set<Element> {
        didSet { expandedChanged(expanded) }
    }

    var expandedChanged: (Set<Element>) -> Void
    let content: () -> (Content)
    let label: () -> (Label)

    internal init(element: Element, expanded: Set<Element> = [],
                  expandedChanged: @escaping (Set<Element>) -> Void = { _ in },
                  content: @escaping () -> (Content),
                  label: @escaping () -> (Label))
    {
        self.element = element
        _expanded = .init(initialValue: expanded)
        self.expandedChanged = expandedChanged
        self.content = content
        self.label = label
    }

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
