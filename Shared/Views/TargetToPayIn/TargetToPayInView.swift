//
//  TargetToPayInView.swift
//  Investing (iOS)
//
//  Created by Sergey Balashov on 30.05.2021.
//

import Combine
import InvestModels
import SwiftUI
import UIKit

@propertyWrapper
struct PriceFormatter {
    private let currency: Currency
    public var value: Double

    init(currency: Currency, value: Double) {
        self.currency = currency
        self.value = value
    }

    var wrappedValue: String {
        get {
            NSNumber(value: value).formatted(currency: currency)
        }
        set {
            if let targetPrice = Double(newValue.string) {
                value = targetPrice
            } else {
                print("not a string")
            }
        }
    }

//    func das() {
//        let oldPrice = oldValue.filter { $0.isNumber }
//        var newPrice = howMuchText.filter { $0.isNumber }
//
//        let isDelete = howMuchText.count < oldValue.count
//        if isDelete, newPrice.count > 1 {
//            print("delete")
//            newPrice.removeLast()
//        }
//
//        if let targetPrice = Double(newPrice) {
//            self.targetPrice = targetPrice
//
//            let formatted = NSNumber(value: targetPrice).formatted(currency: currency)
//
//            if howMuchText != formatted {
//                howMuchText = formatted
//            }
//        }
//    }
}

class TargetToPayInViewModel: EnvironmentCancebleObject, ObservableObject {
    var latest: LatestCurrencyService { env.api().currencyPairLatest() }

    @Published var howOfften: HowOfften = .week
    @Published var targetDate = Date().years(value: 1)
    @Published var currency: Currency {
        didSet { targetPriceText = targetPriceText }
    }

    @Published var targetPriceText: String = "" {
        didSet {
            env.settings.targetTotalPortfolio = targetPrice.addCurrency(currency)
        }
    }

    var targetPrice: Double {
        Double(targetPriceText.filter { $0.isNumber }) ?? 0
    }

    @Published var totalInProfile: Double = 0

    override init(env: Environment = .current) {
        targetPriceText = env.settings.targetTotalPortfolio?.value.string(f: ".0") ?? ""
        currency = env.settings.targetTotalPortfolio?.currency ?? .RUB

        targetDate = env.settings.targetDate

        super.init(env: env)
    }

    override func bindings() {
        super.bindings()
        Publishers.CombineLatest(env.positionService.$positions, $currency)
            .map { [unowned self] positions, currency in
                positions.reduce(MoneyAmount(currency: currency, value: 0)) { result, position in
                    result + position.totalInProfile.convert(to: currency, pair: latest.latest)
                }.value
            }
            .assign(to: \.totalInProfile, on: self)
            .store(in: &cancellables)

        $targetDate.sink(receiveValue: { [unowned self] date in
            env.settings.targetDate = date
        }).store(in: &cancellables)

//        Publishers.CombineLatest($targetPriceText, $currency)
//            .sink(receiveValue: { [unowned self] _, currency in
//
//            }).store(in: &cancellables)
    }

    func load() {
        env.positionService.getPositions()
    }
}

struct TargetToPayInView: View {
    @ObservedObject var viewModel: TargetToPayInViewModel

    var body: some View {
        ScrollView(.vertical) {
            HStack {
                Text("Когда?")
                DatePicker("",
                           selection: $viewModel.targetDate,
                           displayedComponents: .date)
                    .labelsHidden()
            }
            .padding()

            HStack {
                currencySegments
                Spacer()
                howMuch
            }
            .padding()

            Spacer()
            Divider()
            plans
        }
        .navigationTitle("Целевая стоимость")
//        .navigationBarItems(trailing: saveButton)
        .onAppear(perform: viewModel.load)
    }

    var currencySegments: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach([Currency.RUB, .USD, .EUR], id: \.self) { currency in
                    BackgroundButton(title: currency.rawValue,
                                     isSelected: viewModel.currency == currency) {
                        viewModel.currency = currency
                    }
                }
            }.font(.system(size: 17, weight: .semibold))
        }
    }

    var howMuch: some View {
        TextField("1 000 000", text: $viewModel.targetPriceText.allowing(currency: viewModel.currency))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .font(.system(size: 20, weight: .bold))
    }

    var plans: some View {
        VStack(spacing: 16) {
            HStack {
                Button("\(viewModel.howOfften.localized) осталось", action: {
                    viewModel.howOfften = .init(rawValue: viewModel.howOfften.rawValue + 1) ?? .day
                })
                Spacer()
                Text(distance.string(f: ".2"))
            }

            HStack {
                Text("Каждый \(viewModel.howOfften.localized) пополнять")
                Spacer()
                Text(payment)
            }

            HStack {
                Text("Цель достигнута на ")
                Spacer()
                Text(percent.string(f: ".2") + "%")
            }
        }
        .padding()
    }

    var percent: Double {
        (viewModel.totalInProfile / viewModel.targetPrice) * 100
    }

    var payment: String {
        let needAdd = viewModel.targetPrice - viewModel.totalInProfile
        let payment = needAdd / distance

        return NSNumber(value: payment).formatted(currency: viewModel.currency)
    }

    var distance: Double {
        var days = Date().distance(to: viewModel.targetDate) / 60 / 60 / 24
        switch viewModel.howOfften {
        case .day: break
        case .week:
            days /= 7
        case .month:
            days /= 365 * 12
        }
        return max(days, 1)
    }
}

//
// struct Preview: PreviewProvider {
//    static var previews: some View {
//        TargetToPayInView(viewModel: .init())
//    }
// }

enum HowOfften: Int, Localizbles, CaseIterable {
    case day, week, month

    var localized: String {
        switch self {
        case .day:
            return "Дней"
        case .week:
            return "Недель"
        case .month:
            return "Месяцев"
        }
    }
}

private extension NSNumber {
    func formatted(currency: Currency) -> String {
        let formater = NumberFormatter()
        formater.usesGroupingSeparator = true
        formater.groupingSeparator = " "
        formater.numberStyle = .currency
        formater.locale = currency.locale
        formater.minimumFractionDigits = 0

        return formater.string(from: self).orEmpty
    }
}

extension Binding where Value == String {
    func allowing(currency: Currency) -> Self {
        Binding(get: {
                    if let double = Double(wrappedValue.filter { $0.isNumber }) {
                        return NSNumber(value: double).formatted(currency: currency)
                    }

                    return ""
                },
                set: { newValue in
                    print("new", newValue, "old", wrappedValue)
                    let oldPrice = wrappedValue.filter { $0.isNumber }
                    let newPrice = newValue.filter { $0.isNumber }

                    let isDeleteNotNumber = oldPrice == newPrice && wrappedValue.count < newValue.count

                    if isDeleteNotNumber {
                        var new = newValue
                        new.removeLast()
                        wrappedValue = new
                    } else {
                        wrappedValue = newValue
                    }
                })
    }
}
