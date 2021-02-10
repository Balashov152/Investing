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

extension SettingsTabViewModel {
    struct Section: Hashable {
        let type: TypeSection

        enum TypeSection: Hashable, CaseIterable {
            case analytics, session
            var localized: String {
                switch self {
                case .session:
                    return "Session"
                case .analytics:
                    return "Analytics"
                }
            }
        }
    }
}

class SettingsTabViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var startDate: Date = Settings.shared.dateInterval.start
    @Published var endDate: Date = Settings.shared.dateInterval.end

    @Published var adjustedAverage: Bool = Settings.shared.adjustedAverage

    @Published var sections: [Section] = Section.TypeSection.allCases.map(Section.init)

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

        $adjustedAverage.sink(receiveValue: { adjustedAverage in
            Settings.shared.adjustedAverage = adjustedAverage
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
        .padding([.top, .bottom], 8)
    }

    var adjustedAverage: some View {
        Toggle("Adjusted average price", isOn: $viewModel.adjustedAverage)
            .disabled(!isMe)
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
