//
//  SettingsView.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 25.12.2020.
//

import Combine
import InvestModels
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userSession: UserSession
    @ObservedObject var viewModel: SettingsViewModel

    let currentYear = Date().endOfYear.year
    let formatter = DateFormatter.format("yyyy")

    var startRange: [Date] {
        let range = 2018 ... viewModel.endDate.year

        return range.compactMap { year -> Date? in
            formatter.date(from: year.string)
        }
    }

    var endRange: [Date] {
        let range = viewModel.startDate.year ... currentYear

        return range.compactMap { year -> Date? in
            formatter.date(from: year.string)
        }
    }

    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.type) { section in
                Section(header: Text(section.type.localized)) {
                    switch section.type {
                    case .session:
                        VStack {
                            tokenApi
                            Divider()
                            exitButton
                        }
                    case .analytics:
                        VStack {
                            togglesView
                            /*
                             Divider()
                             startPicker
                             endPicker
                             */
                        }.padding([.top, .bottom], 8)
                    }
                }
            }
        }
        .onAppear(perform: viewModel.load)
        .listStyle(GroupedListStyle())
        .navigationTitle("Settings".localized)
    }

    var startPicker: some View {
        VStack(alignment: .leading) {
            Text("start period".localized)
                .font(.system(size: 12))
            Picker("", selection: $viewModel.startDate) {
                ForEach(startRange, id: \.self) {
                    Text(formatter.string(from: $0))
                }
            }.pickerStyle(SegmentedPickerStyle())
        }
    }

    var endPicker: some View {
        VStack(alignment: .leading) {
            Text("end period".localized)
                .font(.system(size: 12))
            Picker("", selection: $viewModel.endDate) {
                ForEach(endRange, id: \.self) { date in
                    Text(formatter.string(from: date))
                }
            }.pickerStyle(SegmentedPickerStyle())
        }
    }

    var tokenApi: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Current token".localized).bold()
            Text(Storage.token)
        }
    }

    var exitButton: some View {
        ActionButton(title: "Quit".localized) {
            Storage.clear()
            userSession.isAuthorized = false
        }
        .buttonStyle(PlainButtonStyle())
        .padding([.top, .bottom], 8)
    }

    var togglesView: some View {
        VStack {
            adjustedAverage
            Divider()
            adjustedTotal
            Divider()
            deleteOther
        }
    }

    var adjustedAverage: some View {
        Toggle("Adjusted average price".localized, isOn: $viewModel.adjustedAverage)
            .font(.system(size: 15))
    }

    var adjustedTotal: some View {
        Toggle("Adjusted total portfolio".localized, isOn: $viewModel.adjustedTotal)
            .font(.system(size: 15))
    }

    var deleteOther: some View {
        Toggle("Minus debt from total portfolio".localized, isOn: $viewModel.minusDebt)
            .font(.system(size: 15))
            .disabled(viewModel.env.settings.blockedPosition.isEmpty)
    }
}
