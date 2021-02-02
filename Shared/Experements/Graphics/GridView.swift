//
//  GridView.swift
//  Investing
//
//  Created by Sergey Balashov on 25.01.2021.
//

import Foundation
import SwiftUI

struct Measurement {
    let date: Date
    let total: Double
}

// class ContentViewModel: EnvironmentCancebleObject, ObservableObject {
//    let totalDate: []
//
//
//    override func bindings() {
//        super.bindings()
//        env.api().operationsService.$operations
//            .receive(on: DispatchQueue.global())
//            .map { operations in
//                let sorted = operations.sorted(by: { $0.date < $1.date })
//                sorted.first?.date
//            }
//    }
//
//    func sumPrecipitation(_ month: Int) -> Double {
//      self.measurements.filter {
//        Calendar.current.component(.month, from: $0.date) == month + 1
//      }.reduce(0, { $0 + $1.precipitation })
//    }
//
//    func monthAbbreviationFromInt(_ month: Int) -> String {
//      let ma = Calendar.current.shortMonthSymbols
//      return ma[month]
//    }
// }

struct ContentView: View {
//    @ObservedObject var viewModel: ContentViewModel
    var value: CGFloat = 0
    var week: String = ""

    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                Capsule().frame(width: 30, height: value)
                    .foregroundColor(Color(red: 0.6666070223, green: 0.6667048931, blue: 0.6665855646))
                Capsule().frame(width: 30, height: value)
                    .foregroundColor(Color(.white))
                Capsule().frame(width: 30, height: value)
                    .foregroundColor(Color(.white))
                Capsule().frame(width: 20, height: value)
                    .foregroundColor(Color(.white))
                Capsule().frame(width: 20, height: value)
                    .foregroundColor(Color(.white))
            }
            Text(week)
        }
    }

    var menu: some View {
        Menu("Actions") {
            Button("Duplicate", action: {})
            Button("Rename", action: {})
            Button("Delete…", action: {})
            Menu("Copy") {
                Button("Copy", action: {})
                Button("Copy Formatted", action: {})
                Button("Copy Library Path", action: {})
            }
        }
    }
}

struct ContentViewPreview: PreviewProvider {
    static var previews: some View {
        Slider(value: .constant(.random(in: 0.2 ... 0.8)), in: 0 ... 1)
//            .fixedSize(horizontal: true, vertical: false)
//            .frame(width: 100, height: 100)
//            .rotationEffect(Angle(degrees: -90))

//            .background(Color.red)
    }
}
