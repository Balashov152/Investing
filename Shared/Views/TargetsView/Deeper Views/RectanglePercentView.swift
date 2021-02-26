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

    internal init(column: TargetsViewModel.Column, target: Binding<Double>) {
        self.column = column
        _target = target
    }

    // private
    @State private var rect: CGRect = .zero
    @State private var isDragging: Bool = false

    @State private var offset: CGFloat = 40
    @State private var ancor: CGFloat = 40

    var thumbSize: CGSize {
        CGSize(width: 3, height: rect.size.height)
    }

    var body: some View {
        GeometryReader { geometry in
            makeView(geometry: geometry)
        }
    }

    var targetView: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                let newOffset = range(min: 0, element: value.translation.width + self.ancor, max: rect.width - thumbSize.width)
                self.offset = newOffset
                debugPrint("offset", offset)

                let off = newOffset == 0 ? 0 : newOffset + thumbSize.width
                let newTarget = off / rect.width * 100
                debugPrint("newTarget", newTarget)
                self.target = Double(range(min: 0, element: newTarget, max: 100))
            }
            .onEnded { value in
                self.ancor = range(min: 0, element: value.translation.width + self.ancor, max: rect.width - thumbSize.width)
                self.isDragging = false
            }

        // a long press gesture that enables isDragging
        let pressGesture = LongPressGesture(minimumDuration: 0.05)
            .onEnded { _ in
                Vibration.selection.vibrate()
                self.isDragging = true
            }

        // a combined gesture that forces the user to long press then drag
        let combined = pressGesture.sequenced(before: dragGesture)

        return RoundedRectangle(cornerRadius: 3)
            .fill(Color.black)
            .scaleEffect(CGSize(width: 1, height: isDragging ? 1.5 : 1))
            .frame(width: thumbSize.width, height: thumbSize.height * 1.2)
            .offset(CGSize(width: offset, height: 0))
            .gesture(combined)
            .padding(.all, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
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
