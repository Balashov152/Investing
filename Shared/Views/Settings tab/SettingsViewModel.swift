//
//  SettingsViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 12.02.2021.
//

import Combine
import InvestModels
import SwiftUI

extension SettingsViewModel {
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

class SettingsViewModel: EnvironmentCancebleObject, ObservableObject {
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
