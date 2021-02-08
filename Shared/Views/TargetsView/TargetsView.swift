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

    let height: CGFloat = UIScreen.main.bounds.height * 0.2
    var multiplicator: CGFloat {
        (viewModel.columns.map { $0.percent }.max() ?? 0) > 0.5 ? 1 : 2
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .bottom) {
                        ForEach(viewModel.columns) { column in
                            ColumnView(column: column,
                                       mainSize: CGSize(width: 20, height: height * multiplicator),
                                       changeTarget: targetChange(coloumn: column))
                        }
                    }
                }
                .frame(height: height, alignment: .bottom)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                List {
                    PlainSection(header: Text("Positions").bold().font(.title).padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))) {
                        ForEach(viewModel.columns) {
                            InfoRow(label: $0.position.name.orEmpty, text: $0.percentVisible.string(f: ".5"))
                        }
                    }
                }
            }
            .navigationTitle("Targets")
//            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.load)
        }
    }
}

public func range<E: Comparable>(min: E, element: E, max: E) -> E {
    return Swift.min(Swift.max(min, element), max)
}
