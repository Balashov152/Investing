//
//  PercentText.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import SwiftUI

struct PercentText: View {
    let percent: Double
    var body: some View {
        Text(percent.string(f: ".2") + "%")
            .foregroundColor(.currency(value: percent))
    }
}
