//
//  InstrumentDetailsView.swift
//  Investing
//
//  Created by Sergey Balashov on 04.04.2022.
//

import Combine
import SwiftUI

struct InstrumentDetailsBlockViewModel: Identifiable, Hashable {
    var id: String { accountName }

    let accountName: String
    let operations: [OperationRowModel]
}

struct InstrumentDetailsView: View {
    @ObservedObject private var viewModel: InstrumentDetailsViewModel
    @State private var expanded: Set<InstrumentDetailsBlockViewModel> = []

    init(viewModel: InstrumentDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            Color.litleGray.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.operations) { operation in
                        OperationRow(viewModel: operation)
                            .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.share?.name ?? "Детали по инструменту")
        .addLifeCycle(operator: viewModel)
    }
}
