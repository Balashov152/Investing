//
//  TargetsView.swift
//  Investing
//
//  Created by Sergey Balashov on 28.01.2021.
//

import Combine
import InvestModels
import SwiftUI

struct TargetsView: View {
    @ObservedObject var viewModel: TargetsViewModel
    @State var showingDetail = false
    @State var showingRates = false

    func targetChange(column: TargetsViewModel.Column) -> Binding<Double> {
        .init {
            viewModel.targets[column.position.ticker] ?? column.percentVisible
        } set: { newValue in
            viewModel.targets.updateValue(newValue, forKey: column.position.ticker)
        }
    }

    let height: CGFloat = UIScreen.main.bounds.height * 0.3
    var multiplicator: CGFloat {
        (viewModel.columns.map { $0.percent }.max() ?? 0) > 0.5 ? 1 : 2
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(viewModel.columns) { column in
                    TargetOneView(column: column, target: targetChange(column: column))
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing], 16)
                    Divider()
                }
            }
            .navigationTitle("Targets")
            .navigationBarItems(trailing: MainView.settingsNavigationLink)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.load)
        }
    }
}

public func range<E: Comparable>(min: E, element: E, max: E) -> E {
    return Swift.min(Swift.max(min, element), max)
}

struct TargetOneView: View {
    let column: TargetsViewModel.Column
    @Binding var target: Double

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8.0) {
                Text(column.position.name)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }

            HStack {
                RectanglePercentView(column: column, target: $target)
                    .frame(height: 10)
                Stepper("", value: $target, in: 0 ... 100)
                    .labelsHidden()
            }

            HStack {
                Text(column.percentVisible.string(f: ".2") + "%")
                Text("->")
                Text(target.string(f: ".2") + "%")
            }.font(.system(size: 16, weight: .medium))

//            HStack {}
        }
    }
}
