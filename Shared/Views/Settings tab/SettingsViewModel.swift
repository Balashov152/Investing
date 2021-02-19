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
    @Published var startDate: Date
    @Published var endDate: Date

    @Published var adjustedAverage: Bool {
        willSet {
            env.settings.adjustedAverage = newValue
        }
    }

    @Published var adjustedTotal: Bool {
        willSet {
            env.settings.adjustedTotal = newValue
        }
    }

    @Published var sections: [Section] = Section.TypeSection.allCases.map(Section.init)

    override init(env: Environment = .current) {
        startDate = env.settings.dateInterval.start
        endDate = env.settings.dateInterval.end

        adjustedAverage = env.settings.adjustedAverage
        adjustedTotal = env.settings.adjustedTotal

        super.init(env: env)
    }

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
