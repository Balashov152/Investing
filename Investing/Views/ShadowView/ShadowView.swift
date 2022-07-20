//
//  ShadowView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.06.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct ShadowView<Content: View>: View {
    let content: () -> (Content)
    let radius: CGFloat = 12

    var body: some View {
        content()
            .background(Color.white)
            .cornerRadius(radius)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .shadow(
                color: .appBlack.opacity(0.2),
                radius: radius,
                x: 0, y: 3
            )
    }
}

/*
 struct ShadowViewPreview: PreviewProvider {
     static var previews: some View {
         ShadowView {
             PositionRowView(position: PositionView(currency:
                 .init(currency: .RUB,
                       balance: 200, blocked: 0),
                 percentInProfile: 150))
                 .padding(.horizontal, 16)
         }
         .previewLayout(.sizeThatFits)
     }
 }
 */
