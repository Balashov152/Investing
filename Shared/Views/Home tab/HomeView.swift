//
//  HomeView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import InvestModels
import Moya
import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State var isShowingPopover = false
    @State var showingDetail = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                convertView
                list
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var totalTitleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Total profile")
                    .font(.largeTitle).bold()
                Spacer()

                Button(action: {
                    self.showingDetail.toggle()
                }) {
                    Text("Show Detail")
                }.sheet(isPresented: $showingDetail) {
                    Text("Detail View")
                }.buttonStyle(PlainButtonStyle())
            }
            ForEach(viewModel.positions.map { $0.currency }.unique.sorted(by: >).enumeratedArray(), id: \.element) { index, currency in
                if index != 0 {
                    Divider()
                }
                TotalView(currency: currency, positions: viewModel.positions)
            }
        }
    }

    var convertView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Text("Convert positions")
                        .font(.system(size: 20, weight: .medium))
                    Spacer(minLength: 16)
                    segment
                }
            }.padding()

            Divider()
        }
    }

    var segment: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(viewModel.positions.map { $0.currency }.unique.sorted(by: >), id: \.self) { currency in
                    BackgroundButton(title: currency.rawValue, isSelected: viewModel.convertType == .currency(currency)) {
                        if viewModel.convertType == .currency(currency) {
                            viewModel.convertType = .original
                        } else {
                            viewModel.convertType = .currency(currency)
                        }
                    }
                }
            }.font(.system(size: 17, weight: .semibold))
        }
    }

    var list: some View {
        List {
            totalTitleView
            ForEach(viewModel.sections, id: \.self) { section in
                Section {
                    PlainSection(header: HeaderView(section: section)) {
                        ForEach(section.positions,
                                id: \.self, content: { position in
                                    PositionRowView(position: position)
                                        .background(
                                            NavigationLink(destination: Text("Somewhere")) {
                                                EmptyView()
                                            }
                                            .hidden()
                                        )

                                })
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
    }

    var currencies: some View {
        Section {
            PlainSection(header: HeaderView(section: .init(type: .Currency, positions: []))) {
                ForEach(viewModel.currencies, id: \.self) { currency in
                    HStack {
                        Text(currency.currency.rawValue)
                        Spacer()
                        MoneyText(money: .init(currency: currency.currency, value: currency.balance))
                    }
                }
            }
        }
    }
}
