//
//  RealmBrokerAccount.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2022.
//

import Foundation
import RealmSwift

public class RealmBrokerAccount: Object {
    @Persisted(primaryKey: true) public var id: String = ""
    @Persisted public var type: String = ""
    @Persisted public var name: String = ""

    @Persisted public var isSelected: Bool = false

    @Persisted public var operations = List<RealmOperation>()
}
