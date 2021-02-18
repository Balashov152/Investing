//
//  HomeHeaderTotalView.swift
//  Investing
//
//  Created by Sergey Balashov on 18.02.2021.
//

import Foundation
import SwiftUI

struct HomeHeaderTotalView: View {
    @State var showingDetail = false
    @State var showingRates = false

    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        VStack {
            totalTitleView
                .padding([.leading, .trailing, .top], 16)
            Divider()
        }
    }

    var totalTitleView: some View {
        VStack(alignment: .leading, spacing: 50) {
            VStack(alignment: .leading, spacing: 20) {
                convertView
                total
            }
            actionButtonsView
        }
    }

    var convertView: some View {
        HStack {
            Text("You portfolio in")
                .font(.system(size: 20, weight: .medium))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.positions.map { $0.currency }.unique.sorted(by: >), id: \.self) { currency in
                        let isSelected = viewModel.convertType == .currency(currency)
                        BackgroundButton(title: currency.rawValue, isSelected: isSelected) {
                            viewModel.convertType = isSelected ? .original : .currency(currency)
                        }
                    }
                }.font(.system(size: 17, weight: .semibold))
            }
        }
    }

    var total: some View {
        Group {
            switch viewModel.convertType {
            case .original:
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.currenciesInPositions.indexed(), id: \.element) { index, currency in
                            if index != 0 {
                                Divider()
                            }
                            HomeTotalView(model: TotalViewModel(currency: currency, positions: viewModel.positions))
                        }
                    }
                }
            case .currency:
                if let convertedTotal = viewModel.convertedTotal {
                    HomeTotalView(model: convertedTotal)
                } else {
                    ProgressView()
                }
            }
        }.frame(height: 40)
    }

    var actionButtonsView: some View {
        HStack {
            allTimeButton
            ratesButton
        }
    }

    var allTimeButton: some View {
        ActionButton(title: "Detail") {
            self.showingDetail.toggle()
        }
        .sheet(isPresented: $showingDetail) {
            ViewFactory.totalDetailView
        }
        .padding(4)
        .overlay(RoundedRectangle(cornerRadius: 5)
            .stroke(Color.gray, lineWidth: 1)
        )
    }

    var ratesButton: some View {
        Button(action: {
            self.showingRates.toggle()
        }, label: {
            Image(systemName: "arrow.left.arrow.right.circle")
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
        })
            .sheet(isPresented: $showingRates) {
                ViewFactory.ratesView
            }
            .font(.body)
            .padding(4)
            .buttonStyle(PlainButtonStyle())
    }
}
