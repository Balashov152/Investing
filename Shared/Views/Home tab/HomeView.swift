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

class HomeViewModel: MainCommonViewModel {
    struct Section: Hashable {
        let type: InstrumentType
        let positions: [Position]
    }

    var sections: [Section] = [] {
        willSet { objectWillChange.send() }
    }

    override init(mainViewModel: MainViewModel) {
        super.init(mainViewModel: mainViewModel)
        _ = RealmManager.shared

        mainViewModel.$positions
            .receive(on: DispatchQueue.global())
            .map { positions -> [Section] in
                if positions.isEmpty { return [] }
                return [InstrumentType.Stock, .Bond, .Etf].compactMap { type -> Section? in
                    let filtered = positions.filter { $0.instrumentType == .some(type) }
                    if !filtered.isEmpty {
                        return Section(type: type, positions: filtered)
                    }
                    return nil
                }
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.sections, id: \.type) { section in
                    Section(header: HeaderView(section: section)) {
                        ForEach(section.positions,
                                id: \.self, content: PositionRowView.init)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Profile")
            .onAppear(perform: viewModel.mainViewModel.loadPositions)
        }
    }

    var topView: some View {
        Text("")
    }

    struct HeaderView: View {
        let section: HomeViewModel.Section

        var alpha: Double {
            section.positions.reduce(0) { $0 + $1.totalInProfile } - section.positions.reduce(0) { $0 + $1.totalBuyPayment }
        }

        var body: some View {
            HStack {
                Text(section.type.rawValue)
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                Text(alpha.string(f: ".2"))
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.currency(value: alpha))
            }
        }
    }
}

extension EdgeInsets {
    static let zero = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
}

extension Color {
    static func currency(value: Double) -> Color {
        if value == .zero { return .gray }

        return value > 0 ? .green : .red
    }
}
