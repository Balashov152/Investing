//
//  ColumnView.swift
//  Investing
//
//  Created by Sergey Balashov on 04.02.2021.
//

import Foundation
import InvestModels
import SwiftUI

struct ColumnView: View {
    internal init(column: TargetsViewModel.Column,
                  mainSize: CGSize,
                  changeTarget: Binding<Double>)
    {
        let startedOffset = CGFloat(abs(1 - column.target)) * mainSize.height - mainSize.height / 2
        _offset = .init(initialValue: startedOffset)
        self.column = column
        self.mainSize = mainSize
        self.changeTarget = changeTarget
    }

    let column: TargetsViewModel.Column
    let mainSize: CGSize
    let changeTarget: Binding<Double>

    private let thumbSize = CGSize(width: 20, height: 3)
    private let targetValueViewSize = CGSize(width: 20, height: 20)

    @State var offset: CGFloat = .zero

    @State var isDragging: Bool = false

    var offsetCorrectHeight: CGFloat {
        targetValueViewSize.height / 2 + thumbSize.height / 2
    }

    var targetViewOffset: CGSize {
        CGSize(width: targetValueViewSize.width / 1.5,
               height: offset)
    }

    var targetPercent: Double {
        let start = mainSize.height
        let now = offset - mainSize.height / 2
        return abs(Double(now / start) * 100)
    }

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    RoundedRectangle(cornerRadius: 3)
                        .stroke(Color.black.opacity(0.8), lineWidth: 1)
                        .frame(width: mainSize.width, height: mainSize.height)

                    VStack {
                        Rectangle()
                            .foregroundColor(Color(UIColor.systemBlue))
                            .frame(width: mainSize.width,
                                   height: mainSize.height * CGFloat(column.percent), alignment: .bottom)
                            .cornerRadius(3)
                    }
                }
                targetView
            }

            Text(column.percentVisible.string(f: ".2") + "%")
                .font(.system(size: mainSize.width / 2, weight: .light))
                .multilineTextAlignment(.center)

            URLImage(position: column.position)
                .frame(width: mainSize.width, height: mainSize.width)
                .background(Color.litleGray)
                .cornerRadius(mainSize.width / 2)
        }
    }

    var targetView: some View {
        let dragGesture = DragGesture()
            .onChanged { value in
                debugPrint("value.translation", value.translation)
                let newOffset = value.startLocation.y + value.translation.height
                let amplutude = mainSize.height / 2
                self.offset = range(min: -amplutude, element: newOffset, max: amplutude)
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

        return HStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.black) // (red: 29 / 255, green: 255 / 255, blue: 190 / 255)
                .scaleEffect(CGSize(width: isDragging ? 1.5 : 1, height: 1.0))
                .frame(width: thumbSize.width, height: thumbSize.height)

            Text(targetPercent.string(f: ".0") + "%")
                .font(.system(size: 8))
        }
        .frame(height: targetValueViewSize.height)
        .offset(targetViewOffset)
        .gesture(combined)
    }

    var gesture: some Gesture {
        let dragGesture = DragGesture()
            .onChanged { value in
                debugPrint("value.translation", value.translation)
                let newOffset = value.startLocation.y + value.translation.height
                let amplutude = mainSize.height / 2
                self.offset = range(min: -amplutude, element: newOffset, max: amplutude)
            }
            .onEnded { _ in
                self.isDragging = false
            }

        let pressGesture = LongPressGesture(minimumDuration: 0.1)
            .onEnded { _ in
                Vibration.selection.vibrate()
                self.isDragging = true
            }

        return pressGesture.sequenced(before: dragGesture)
    }
}

struct ContentView: View {
    @State var pos = CGSize.zero
    @State var acc = CGSize.zero
    @State var value = 0.0

    @ObservedObject var model = Model()

    var body: some View {
        let drag = DragGesture()
            .onChanged { value in
                self.pos = CGSize(width: value.translation.width + self.acc.width, height: value.translation.height + self.acc.height)
            }
            .onEnded { value in
                self.pos = CGSize(width: value.translation.width + self.acc.width, height: value.translation.height + self.acc.height)
                self.acc = self.pos
            }

        return VStack {
            Slider(value: $value, in: 0 ... 100, step: 1) { _ in
                self.model.flag = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.model.flag = true
                }
            }
        }
        .frame(width: 250, height: 40, alignment: .center)
        .overlay(RoundedRectangle(cornerRadius: 25).stroke(lineWidth: 2).foregroundColor(Color.black))
        .offset(x: self.pos.width, y: self.pos.height)
        .gesture(model.flag == true ? drag : nil)
    }
}

class Model: ObservableObject {
    @Published var flag = false
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
