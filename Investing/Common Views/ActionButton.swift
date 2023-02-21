//
//  ActionButton.swift
//  Investing
//
//  Created by Sergey Balashov on 10.02.2021.
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action, label: {
            Text(title)
                .font(.title3)
                .frame(maxWidth: .infinity, minHeight: 50)
                .multilineTextAlignment(.center)
                .background(Color.litleGray)
                .cornerRadius(5)
        })
    }
}
