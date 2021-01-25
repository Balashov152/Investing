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

    var body: some View {
        HStack {
            // 2
            ForEach(0 ..< 12) { month in
                // 3
                VStack {
                    // 4
                    Spacer()
                    // 5
                    ZStack(alignment: .bottom) {
                    Rectangle()
//                        .inset(by: 4)
                        .fill(Color.green)
                        .frame(width: 20,
                               height: CGFloat.random(in: 100 ... 300))
                        .cornerRadius(3)
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 20,
                                   height: CGFloat.random(in: 100 ... 300))
                            .cornerRadius(3)
                            .opacity(0.8)
                    }
                    // 6
                    Text(month.string)
                        .font(.footnote)
                        .frame(height: 20)
                }
            }
        }
    }
}

//struct ContentViewPreview: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
