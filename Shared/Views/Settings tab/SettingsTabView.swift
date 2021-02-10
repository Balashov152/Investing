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
            case token, date, exit
            var localized: String {
                switch self {
                case .token:
                    return "API Token"
                case .date:
                    return "Date interval"
                case .exit:
                    return "Logout"
                }
            }
        }
    }

    @State var token: String = Storage.token

    @Published var startDate: Date = Settings.shared.dateInterval.start
    @Published var endDate: Date = Settings.shared.dateInterval.end

    @Published var sections: [Section] = [Section(type: .token), Section(type: .date), Section(type: .exit)]

    override func bindings() {
        super.bindings()
        Publishers.CombineLatest($startDate, $endDate)
            .dropFirst()
            .map { startDate, endDate in
                DateInterval(start: startDate, end: endDate)
            }
            .sink(receiveValue: { dateInterval in
                Settings.shared.dateInterval = dateInterval
            }).store(in: &cancellables)
    }
}

struct SettingsTabView: View {
    @EnvironmentObject var userSession: UserSession
    @ObservedObject var viewModel: SettingsTabViewModel
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
                    case .token:
                        tokenApi
                    case .date:
                        VStack {
                            startPicker
                            endPicker
                        }
                    case .exit:
                        exitButton
                    }
                }
            }

        }.navigationTitle("Settings")
    }

    var startPicker: some View {
        VStack(alignment: .leading) {
            Text("start period")
                .font(.system(size: 10))
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
                .font(.system(size: 10))
            Picker("", selection: $viewModel.endDate) {
                ForEach(endRange, id: \.self) { date -> Text in
                    Text(formatter.string(from: date))
                }
            }.pickerStyle(SegmentedPickerStyle())
        }
    }

    var tokenApi: some View {
        VStack(alignment: .leading) {
            Text(Storage.token)
        }
    }

    var exitButton: some View {
        Button("Quit", action: {
            Storage.token = ""
            userSession.isAuthorized = false
        })
            .multilineTextAlignment(.center)
            .buttonStyle(PlainButtonStyle())
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
