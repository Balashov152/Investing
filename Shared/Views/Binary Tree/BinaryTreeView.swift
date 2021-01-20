//
//  BinaryTreeView.swift
//  Investing
//
//  Created by Sergey Balashov on 19.01.2021.
//

import Combine
import Foundation
import SwiftUI

class Node<T: CustomStringConvertible>: Identifiable, Hashable {
    static func == (lhs: Node<T>, rhs: Node<T>) -> Bool {
        lhs.hashValue == rhs.hashValue
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(data.description)
    }

    var data: T
    var children: [Node] = []
    weak var parent: Node?

    init(_ data: T) {
        self.data = data
    }
}

class BinaryTreeViewModel: CancebleObject, ObservableObject {
    @Published var tree = Node<String>("root")
}

struct BinaryTreeView: View {
    @ObservedObject var viewModel: BinaryTreeViewModel

    var body: some View {
        levelView(node: viewModel.tree)
//        viewModel.tree
    }

    func levelView(node: Node<String>) -> some View {
        Group {
            if node.children.isEmpty {
                VStack {
                    Text(node.data.description)
                }
            } else {
                hStack(cildrens: node.children)
            }
        }
    }

    func hStack(cildrens: [Node<String>]) -> some View {
        HStack {
            ForEach(cildrens, content: { node in
                levelView(node: node)
            })
        }
    }
}

// struct BinaryTreeView_Previews: PreviewProvider {
//    static var previews: some View {
//        BinaryTreeView()
//    }
// }
