//
//  Localizator.swift
//  SellFashion
//
//  Created by Sergey Balashov on 22/07/2019.
//  Copyright © 2019 Sellfashion. All rights reserved.
//

import Foundation

public class Localizator {
    public static let shared = Localizator()
    private init() {}

    lazy var localizableDictionary: NSDictionary = {
        guard let path = Bundle(for: Localizator.self).path(forResource: "Localizable", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path)
        else {
            assertionFailure("Localizable file NOT found")
            return [:]
        }
        return dict
    }()

    public func localize(string: String) -> String {
        var localizedString = string

        if let string = localizableDictionary.value(forKey: string) as? String { // if simple word
            localizedString = string
        } else if let dict = localizableDictionary.value(forKey: string) as? NSDictionary, // if word dictionary, with value and comment
                  let string = dict.value(forKey: "value") as? String
        {
            localizedString = string
        }
//        else {
//            assertionFailure("Missing translation for: ---\n\n\(string)\n\n---")
//        }
        return localizedString.isEmpty ? string : localizedString // for empty just return key
    }
}

public extension String {
    var localized: String {
        return Localizator.shared.localize(string: self)
    }
}
