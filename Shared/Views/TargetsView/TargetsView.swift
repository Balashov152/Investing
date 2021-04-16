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
            viewModel.targets[column.position.ticker] ?? column.target
        } set: { newValue in
            viewModel.targets.updateValue(newValue, forKey: column.position.ticker)
        }
    }

    let height: CGFloat = UIScreen.main.bounds.height * 0.3
    var multiplicator: CGFloat {
        (viewModel.columns.map { $0.percent }.max() ?? 0) > 0.5 ? 1 : 2
    }

    var totalPrecent: Double {
        viewModel.targets.reduce(0) { $0 + $1.value }
    }

    var body: some View {
        NavigationView {
            VStack {
                InfoRow(label: "Total",
                        text: totalPrecent.percentFormat)
                    .font(.title3)
                    .padding()

                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(viewModel.columns) { column in
                        TargetOneView(column: column,
                                      total: viewModel.total,
                                      target: targetChange(column: column))
                            .padding([.top, .bottom], 8)
                            .padding([.leading, .trailing], 16)
                        Divider()
                    }
                }
            }
            .navigationTitle("Targets".localized)
            .navigationBarItems(leading: EditButton(), trailing: MainView.settingsNavigationLink)
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
    let total: Double

    @Binding var target: Double

    var changeCount: Double {
        let changePercent = target - column.percentVisible
        let changeValue = total * changePercent / 100
        let changeCount = changeValue / column.position.averageNow.value

        return changeCount
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8.0) {
                Text(column.position.name)
                    .font(.system(size: 14, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
            }

            HStack(alignment: .center) {
                RectanglePercentView(column: column, target: $target)
                    .frame(height: 10)
                Stepper("", value: $target, in: 0 ... 100)
                    .labelsHidden()
            }

            HStack {
                HStack {
                    Text(column.percentVisible.percentFormat)
                    Text("->")
                    Text(target.percentFormat)
                }.onTapGesture {
                    target = column.percentVisible
                }
                Spacer()
                HStack {
//                    Text("Что бы достичь нужного процента")
                    if changeCount != 0 {
                        Image(systemName: "triangle.fill")
                            .resizable()
                            .frame(square: 20)
                            .rotationEffect(Angle(degrees: changeCount > 0 ? 0 : 180))
                            .foregroundColor(.currency(value: changeCount))

                        Text(changeCount.string(f: ".2") + "pcs".localized)
                    }
                }

            }.font(.system(size: 16, weight: .medium))
        }
    }
}

public extension View {
    @inlinable
    func frame(square: CGFloat, alignment: Alignment = .center) -> some View {
        frame(width: square, height: square, alignment: alignment)
    }
}

extension Double {
    var percentFormat: String {
        string(f: ".2") + "%"
    }
}
