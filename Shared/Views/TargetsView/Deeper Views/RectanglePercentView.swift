//
//  ColumnView.swift
//  Investing
//
//  Created by Sergey Balashov on 04.02.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct RectanglePercentView: View {
    let column: TargetsViewModel.Column
    @Binding var target: Double

    @State var rect: CGRect = .zero
    @State var isDragging: Bool = false

    let padding: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            makeView(geometry: geometry)
        }
    }

    var targetView: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                debugPrint("value.translation", value.translation, "value.startLocation", value.startLocation)
                let newOffset = value.translation.width // value.startLocation.x +
                debugPrint("newOffset", newOffset)
                self.target = Double(range(min: 0, element: newOffset, max: 100))
            }
            .onEnded { _ in
                self.isDragging = false
            }

        // a long press gesture that enables isDragging
        let pressGesture = LongPressGesture(minimumDuration: 0.1)
            .onEnded { _ in
                Vibration.selection.vibrate()
                self.isDragging = true
            }

        // a combined gesture that forces the user to long press then drag
        let combined = pressGesture.sequenced(before: dragGesture)

        return RoundedRectangle(cornerRadius: 3)
            .fill(Color.black)
            .scaleEffect(CGSize(width: 1, height: isDragging ? 1.5 : 1))
            .frame(width: 10, height: rect.size.height)
            .offset(CGSize(width: rect.size.width * CGFloat(target / 100), height: 0))
            .gesture(combined)
    }

    func makeView(geometry: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = geometry.frame(in: .global)
        }

        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
            RoundedRectangle(cornerRadius: 3)
                .stroke(Color.black.opacity(0.8), lineWidth: 1)
                .frame(width: geometry.size.width, height: geometry.size.height)

            if column.percent > 0 {
                Rectangle()
                    .foregroundColor(Color(UIColor.systemBlue))
                    .frame(width: geometry.size.width * CGFloat(column.percent),
                           height: geometry.size.height, alignment: .leading)
                    .cornerRadius(3)
            }
            targetView
        }
    }
}

//
// struct Preview: PreviewProvider {
//    static var previews: some View {
//        TargetPositionView(column: TargetsViewModel.Column(percent: 0.30, target: 0.70, position: .tsla), changeTarget: .constant(71))
//            .frame(width: UIScreen.main.bounds.width,
//                   height: 20)
//    }
// }

extension Position {
    static let tsla = Position(name: "Tesla", figi: "fasfa", ticker: "TSLA",
                               isin: nil, instrumentType: .Stock, balance: 5600,
                               blocked: nil, lots: 40,
                               expectedYield: .init(currency: .USD, value: 400),
                               averagePositionPrice: .init(currency: .USD, value: 300),
                               averagePositionPriceNoNkd: nil)
}
