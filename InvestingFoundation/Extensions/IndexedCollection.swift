//
//  IndexedCollection.swift
//  Investing
//
//  Created by Sergey Balashov on 20.01.2021.
//

import Foundation

public struct IndexedCollection<Base: RandomAccessCollection>: RandomAccessCollection {
    public typealias Index = Base.Index
    public typealias Element = (index: Index, element: Base.Element)

    let base: Base

    public var startIndex: Index { base.startIndex }

    public var endIndex: Index { base.endIndex }

    public func index(after i: Index) -> Index {
        base.index(after: i)
    }

    public func index(before i: Index) -> Index {
        base.index(before: i)
    }

    public func index(_ i: Index, offsetBy distance: Int) -> Index {
        base.index(i, offsetBy: distance)
    }

    public subscript(position: Index) -> Element {
        (index: position, element: base[position])
    }
}

public extension RandomAccessCollection {
    func indexed() -> IndexedCollection<Self> {
        IndexedCollection(base: self)
    }
}
