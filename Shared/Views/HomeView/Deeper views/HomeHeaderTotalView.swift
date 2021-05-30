//
//  HomeHeaderTotalView.swift
//  Investing
//
//  Created by Sergey Balashov on 18.02.2021.
//

import Foundation
import SwiftUI

protocol Localizbles {
    var localized: String { get }
}

struct SegmentView<Item: Hashable & Localizbles>: View {
    let items: [Item]
    @Binding var selected: Item?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(items, id: \.self) { item in
                    BackgroundButton(title: item.localized, isSelected: item == selected) {
                        selected = item
                    }
                }
            }.font(.system(size: 17, weight: .semibold))
        }
    }
}

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
            Text("You portfolio in".localized)
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
                if let convertedTotal = viewModel.convertedTotal,
                   convertedTotal.currency == viewModel.convertType.currencyValue
                {
                    HomeTotalView(model: convertedTotal)
                } else {
                    ProgressView()
                }
            }
        }.frame(height: 40)
    }

    var actionButtonsView: some View {
        HStack {
            ratesButton
            allTimeButton
            sortedButton
        }
    }

    var sortedButton: some View {
        BorderActionButton(action: {
            viewModel.sortType = HomeViewModel.SortType(rawValue: viewModel.sortType.rawValue + 1) ?? .name
        }, content: {
            HStack {
                Image(systemName: viewModel.sortType.systemImageName)
                    .resizable()
                    .frame(width: 15, height: 15, alignment: .center)
                Text(viewModel.sortType.text)
            }
        })
    }

    var allTimeButton: some View {
        BorderActionButton(action: {
            self.showingDetail.toggle()
        }, content: {
            HStack {
                Image(systemName: "list.bullet")
                    .resizable()
                    .frame(width: 15, height: 15, alignment: .center)
                Text("Total".localized)
            }
        })
            .sheet(isPresented: $showingDetail) {
                ViewFactory.totalDetailView
            }
    }

    var ratesButton: some View {
        BorderActionButton(action: {
            self.showingRates.toggle()
        }, content: {
            HStack {
                Image(systemName: "arrow.left.arrow.right.circle")
                    .resizable()
                    .frame(width: 20, height: 20, alignment: .center)
                Text("Rates".localized)
            }

        })
            .sheet(isPresented: $showingRates) {
                ViewFactory.ratesView
            }
    }
}

struct BorderActionButton<Content: View>: View {
    let action: () -> Void
    let content: () -> (Content)

    var body: some View {
        Button(action: action, label: {
            content()
//            .font(.body)
                .padding(4)
                .cornerRadius(5)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 50)
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray, lineWidth: 1)
                )
        })
    }
}
