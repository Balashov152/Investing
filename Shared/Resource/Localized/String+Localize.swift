//
//  String+Localize.swift
//  Investing
//
//  Created by Sergey Balashov on 18.02.2021.
//

import Foundation

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
