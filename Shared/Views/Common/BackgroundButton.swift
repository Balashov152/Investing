//
//  BackgroundButton.swift
//  Investing
//
//  Created by Sergey Balashov on 15.01.2021.
//

import Foundation
import SwiftUI

struct BackgroundButton: View {
    let title: String
    let isSelected: Bool

    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(isSelected ? Color.white : Color.accentColor)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                .background(isSelected ? Color.accentColor : Color(UIColor.litleGray))
                .cornerRadius(6)
                .textCase(nil)
        }
    }
}
