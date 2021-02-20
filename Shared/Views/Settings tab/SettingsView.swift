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
    @State var token: String = Storage.token

    let currentYear = Date().year
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
                            adjustedAverage
                            Divider()
                            adjustedTotal
                            Divider()
                            startPicker
                            endPicker
                        }.padding([.top, .bottom], 8)
                    }
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationTitle("Settings")
    }

    var startPicker: some View {
        VStack(alignment: .leading) {
            Text("start period")
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
            Text("end period")
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
            Text("Current token").bold()
            Text(Storage.token)
        }
    }

    var exitButton: some View {
        ActionButton(title: "Quit") {
            Storage.token = ""
            userSession.isAuthorized = false
        }
        .buttonStyle(PlainButtonStyle())
        .padding([.top, .bottom], 8)
    }

    var adjustedAverage: some View {
        Toggle("Adjusted average price", isOn: $viewModel.adjustedAverage)
            .font(.system(size: 15))
    }

    var adjustedTotal: some View {
        Toggle("Adjusted total portfolio", isOn: $viewModel.adjustedTotal)
            .font(.system(size: 15))
    }
}

struct YearDatePickerView: View {
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    @State private var birthDate = Date()

    var body: some View {
        VStack {
            DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date) {
                Text("Select a date")
            }.datePickerStyle(DefaultDatePickerStyle())

//            Text("Date is \(birthDate, formatter: dateFormatter)")
        }
    }
}
