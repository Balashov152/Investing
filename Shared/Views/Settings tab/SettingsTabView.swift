//
//  CurrencyTabView.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 25.12.2020.
//

import Combine
import InvestModels
import Moya
import SwiftUI

class SettingsTabViewModel: EnvironmentCancebleObject, ObservableObject {
    struct Section: Hashable {
        let type: TypeSection

        enum TypeSection: Hashable {
            case token, date
            var localized: String {
                switch self {
                case .token:
                    return "API Token"
                case .date:
                    return "Date interval"
                }
            }
        }
    }

    @State var token: String = Storage.token

    @Published var startDate: Date = Settings.shared.dateInterval.start
    @Published var endDate: Date = Settings.shared.dateInterval.end

    @Published var sections: [Section] = [Section(type: .token), Section(type: .date)]

    override func bindings() {
        super.bindings()
        Publishers.CombineLatest($startDate, $endDate)
            .dropFirst()
            .map { startDate, endDate in
                DateInterval(start: startDate, end: endDate)
            }.sink(receiveValue: { dateInterval in
                Settings.shared.dateInterval = dateInterval
            }).store(in: &cancellables)
    }
}

struct SettingsTabView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @State var token: String = Storage.token

    var body: some View {
        List {
            ForEach(viewModel.sections, id: \.type) { section in
                Section(header: Text(section.type.localized)) {
                    switch section.type {
                    case .token:
                        tokenApi
                    case .date:
                        HStack {
                            startPicker
                            endPicker
                        }
                    }
                }
            }

        }.navigationTitle("Settings")
    }

    var startPicker: some View {
        DatePicker(selection: $viewModel.startDate, in: ...viewModel.endDate, displayedComponents: .date) { EmptyView() }
            .datePickerStyle(DefaultDatePickerStyle())
    }

    var endPicker: some View {
        DatePicker(selection: $viewModel.endDate, in: viewModel.startDate ... Date(), displayedComponents: .date) { EmptyView() }
            .datePickerStyle(DefaultDatePickerStyle())
    }

    var tokenApi: some View {
        VStack(alignment: .leading) {
            TextField("Enter token", text: $token, onCommit: {
                print("onCommit", token)
            })
        }
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
