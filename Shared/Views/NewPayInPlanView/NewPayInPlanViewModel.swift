//
//  PlansPayInViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 29.04.2021.
//

import Combine
import Foundation
import InvestModels
import SwiftUI

extension NewPayInPlanViewModel.OfftenType: Identifiable {
    var localized: String {
        rawValue
    }
}

class NewPayInPlanViewModel: EnvironmentCancebleObject, ObservableObject {
    typealias OfftenType = PayInPlan.OfftenType

    @Published var selectionOfften: OfftenType = .week
    @Published var howMuchText: String = ""

    @Published var newPlan: PayInPlan?

    private var realmManager: RealmManager { .shared }

    override func bindings() {
        super.bindings()
        Publishers.CombineLatest($selectionOfften,
                                 $howMuchText.map { Int($0) }.eraseToAnyPublisher().unwrap())
            .map { type, money in
                PayInPlan(offtenType: type, money: Double(money))
            }
            .assign(to: \.newPlan, on: self)
            .store(in: &cancellables)
    }

    func savePlanAndBack() {
        if let newPlan = newPlan {
            realmManager.write(objects: [PayInPlanR(payInPlan: newPlan)])
        }
    }
}
