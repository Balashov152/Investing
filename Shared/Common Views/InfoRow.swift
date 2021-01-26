//
//  InfoRow.swift
//  Investing
//
//  Created by Sergey Balashov on 26.01.2021.
//

import Foundation
import SwiftUI

struct InfoRow: View {
    let label: String
    let text: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(text)
        }
    }
}
