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
    @State var token: String = Settings.shared.apiToken

    @Published var startDate: Date = Settings.shared.dateInterval.start
    @Published var endDate: Date = Settings.shared.dateInterval.end

    override func bindings() {
        super.bindings()

        Publishers.CombineLatest($startDate, $endDate)
            .dropFirst()
            .map { startDate, endDate in
                DateInterval(start: startDate, end: endDate)
            }.sink(receiveValue: { dateInterval in
                Settings.shared.dateInterval = dateInterval
            }).store(in: &cancellables)

//        $token.publisher.print()

//            .assign(to: \.operations, on: self)
//            .store(in: &cancellables)
    }

//    public func loadPositions() {
//        realmManager.syncQueueBlock {
//            let objects = realmManager.objects(CurrencyPairR.self,
//                                               sorted: [NSSortDescriptor(key: "date", ascending: false)])
//                .map { CurrencyPair(currencyPairR: $0) }
//
//            DispatchQueue.main.async {
//                self.currencies = objects
//            }
//        }
//    }
}

struct SettingsTabView: View {
    @ObservedObject var viewModel: SettingsTabViewModel
    @State var token: String = Settings.shared.apiToken

    var body: some View {
        NavigationView {
            List {
                tokenApi
                startPicker
                endPicker
//                Section(header: Text("Date interval")) {
//                    DatePicker(selection: viewModel.$endDate, in: ...Date(), displayedComponents: .date) {
//                        Text("End a date")
//                    }.datePickerStyle(DefaultDatePickerStyle())
//                }
            }.navigationTitle("Settings")
//            .onAppear(perform: viewModel.loadPositions)
        }
    }

    var startPicker: some View {
        DatePicker(selection: $viewModel.startDate, in: ...Date(), displayedComponents: .date) {
            Text("Start a date")
        }.datePickerStyle(DefaultDatePickerStyle())
    }

    var endPicker: some View {
        DatePicker(selection: $viewModel.endDate, in: ...Date(), displayedComponents: .date) {
            Text("End a date")
        }.datePickerStyle(DefaultDatePickerStyle())
    }

    var tokenApi: some View {
        VStack(alignment: .leading) {
            Text("API Token")
                .font(.callout)
                .bold()
            Spacer()
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
