//
//  OperationsListView.swift
//  Investing
//
//  Created by Sergey Balashov on 31.01.2022.
//

import Foundation
import SwiftUI

struct OperationsListView: View {
    @ObservedObject private var viewModel: OperationsListViewModel

    init(viewModel: OperationsListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.litleGray.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.operations, id: \.hashValue) { operation in
                            OperationRow(viewModel: operation)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Operations")
            .navigationBarTitleDisplayMode(.inline)
        }
        .addLifeCycle(operator: viewModel)
    }

/*
 VStack {
     ScrollView(.horizontal, showsIndicators: false) {
         LazyHStack(alignment: .center, spacing: Constants.Paddings.m) {
             ForEach(viewModel.figes, id: \.self) { figi in
                 Button(action: {
                     viewModel.selectedFigi = figi
                 }, label: {
                     Text(figi)
                         .foregroundColor(viewModel.selectedFigi == figi ? .purple : .black)
                 })
             }
         }
         .padding(.horizontal)
     }
     .frame(height: 40)
 */
}
