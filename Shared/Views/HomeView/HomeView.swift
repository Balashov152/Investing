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
    @State var showingDetail = false
    @State var showingRates = false

    @State var expandedSections: Set<InstrumentType> {
        willSet {
            viewModel.env.settings.expandedHome = newValue
        }
    }

    init(viewModel: HomeViewModel) {
        _expandedSections = .init(initialValue: viewModel.env.settings.expandedHome)

        self.viewModel = viewModel
    }

    func isExpandedSection(type: InstrumentType) -> Binding<Bool> {
        .init { () -> Bool in
            expandedSections.contains(type)
        } set: { isExpand in
            if isExpand {
                expandedSections.insert(type)
            } else {
                expandedSections.remove(type)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                convertView
                list
            }
            .navigationBarItems(trailing: MainView.settingsNavigationLink)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var totalTitleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Total")
                    .font(.largeTitle).bold()
                Spacer()
                if viewModel.convertType != .original {
                    Button("Detail", action: {
                        self.showingDetail.toggle()
                    }).sheet(isPresented: $showingDetail) {
                        ViewFactory.totalDetailView
                    }
                    .padding(4)
                    .overlay(RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1)
                    )
                    .buttonStyle(PlainButtonStyle())
                }
            }
            Group {
                switch viewModel.convertType {
                case .original:
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.currenciesInPositions.indexed(), id: \.element) { index, currency in
                                if index != 0 { Divider() }
                                HomeTotalView(model: TotalViewModel(currency: currency, positions: viewModel.positions))
                            }
                        }
                    }
                case .currency:
                    if let convertedTotal = viewModel.convertedTotal {
                        HomeTotalView(model: convertedTotal)
                    }
                }
            }
            .frame(height: 44)
            .animation(.easeInOut)
        }
    }

    var convertView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Text("Convert")
                        .font(.system(size: 20, weight: .medium))
                    Spacer(minLength: 16)
                    segment

                    Button(action: {
                        self.showingRates.toggle()
                    }, label: {
                        Image(systemName: "arrow.left.arrow.right.circle")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                    }).sheet(isPresented: $showingRates) {
                        ViewFactory.ratesView
                    }
                    .font(.body)
                    .padding(4)
                    .buttonStyle(PlainButtonStyle())
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
            ForEach(viewModel.sections) { section in
                Section {
                    DisclosureGroup(isExpanded: isExpandedSection(type: section.type),
                                    content: {
                                        groupContent(section: section)
                                    },
                                    label: {
                                        HomeHeaderView(section: section)
                                    })
                }
            }
        }
        .listStyle(GroupedListStyle())
    }

    func groupContent(section: HomeViewModel.Section) -> some View {
        ForEach(section.positions, id: \.self, content: { position in
            switch position.instrumentType {
            case .Stock, .Bond, .Etf:
                PositionRowView(position: position)
                    .background(
                        NavigationLink(destination: NavigationLazyView(ViewFactory.positionDetailView(position: position,
                                                                                                      env: viewModel.env))) {
                            EmptyView()
                        }
                        .hidden()
                    )
            case .Currency:
                CurrencyPositionRowView(position: position)
            }
        })
    }

    var currencies: some View {
        Section {
            PlainSection(header: HomeHeaderView(section: .init(type: .Currency, positions: []))) {
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
