//
//  InstrumentType.swift
//  Investing
//
//  Created by Sergey Balashov on 10.12.2020.
//

import Foundation
import UIKit

public enum InstrumentType: String, Hashable, Codable, CaseIterable {
    case Stock, Currency, Bond, Etf
}
