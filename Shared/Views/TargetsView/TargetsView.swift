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

    func targetChange(coloumn: TargetsViewModel.Column) -> Binding<Double> {
        .init { () -> Double in
            viewModel.targets.first(where: { $0.positionId == coloumn.position.figi.orEmpty })?.target ?? 0
        } set: { newValue in
            if var target = viewModel.targets.first(where: { $0.positionId == coloumn.position.figi.orEmpty }) {
                target.target = newValue
                viewModel.targets.remove(target)
                viewModel.targets.insert(target)
            }
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
                    Divider()
                    TargetOneView(column: column)
                        .padding([.all], 8)
                }
            }
            .navigationTitle("Targets")
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

    @State var target: CGFloat = 50

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 8.0) {
                GeometryReader { _ in
                    Text(column.position.name.orEmpty)
                        .font(.system(size: 14, weight: .bold))
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
//                        .frame(width: geometry.size.width * 0.5)
                }
                Spacer()
                GeometryReader { _ in
                    RectanglePercentView(column: column)
//                        .frame(width: geometry.size.width * 0.5, height: 10)
                }

//                Spacer()
                Text(column.percentVisible.string(f: ".2") + "%")
                    .font(.system(size: 16, weight: .bold))
            }

            HStack {
                Stepper(value: $target, in: 0 ... 100) {
                    EmptyView()
                }
//                .scaleEffect(0.8)
                Text(target.description + "%")
                    .font(.system(size: 16, weight: .medium))
            }

            HStack {}
        }
    }
}
