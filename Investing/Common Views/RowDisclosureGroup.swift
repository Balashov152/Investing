//
//  RowDisclosureGroup.swift
//  Investing
//
//  Created by Sergey Balashov on 27.02.2021.
//

import Foundation
import SwiftUI

struct RowDisclosureGroup<Content: View, Label: View>: View {
    @State private var isExpanded: Bool = false

    let label: () -> Label
    let content: () -> Content
    
    init(
        label: @escaping () -> (Label),
        content: @escaping () -> (Content)
    ) {
        self.label = label
        self.content = content
    }

    var body: some View {
        VStack {
            HStack {
                label()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.default) {
                            isExpanded.toggle()
                        }
                    }
                
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            
            if isExpanded {
                content()
                    .padding(.leading, Constants.Paddings.m)
            }
        }
    }
}
