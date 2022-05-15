//
//  PayInPlansView.swift
//  InvestModels
//
//  Created by Sergey Balashov on 08.05.2021.
//

import Combine
import InvestModels
import SwiftUI

extension PayInPlan: Identifiable {}
extension PayInPlan.OfftenType {
    var allInYear: Int {
        howManyTimes(on: .init(start: Date().startOfDay, end: Date().endOfYear))
    }

    var howManyUntilYear: Int {
        howManyTimes(on: .init(start: Date(), end: Date().endOfYear))
    }

    func howManyTimes(on interval: DateInterval) -> Int {
        switch self {
        case .day:
            return Calendar.current.dateComponents([.day],
                                                   from: interval.start, to: interval.end).day ?? 0
        case .week:
            return Calendar.current.dateComponents([.weekOfYear],
                                                   from: interval.start, to: interval.end).weekOfYear ?? 0
        case .month:
            return Calendar.current.dateComponents([.month], from: interval.start,
                                                   to: interval.end).month ?? 0
        }
    }
}

extension PayInPlan {
    var untilYear: String {
        (Double(offtenType.howManyUntilYear) * money).formattedCurrency()
    }

    var inYear: String {
        (Double(offtenType.allInYear) * money).formattedCurrency()
    }
}

class PayInPlansViewModel: EnvironmentCancebleObject, ObservableObject {
    @Published var plans: [PayInPlan] = []

    private var realmManager: RealmManager { .shared }

    public func load() {
        plans = realmManager.objects(PayInPlanR.self).map { .init(payInPlanR: $0) }
    }
}

struct PayInPlansView: View {
    @ObservedObject var viewModel: PayInPlansViewModel

    var body: some View {
        List(viewModel.plans) { plan in
            PlanView(plan: plan)
        }
        .navigationBarItems(trailing: addNewButton)
        .onAppear(perform: viewModel.load)
    }

    var addNewButton: some View {
        Button(action: {}) {
            NavigationLink(destination: ViewFactory.newPayInPlanView) {
                Image(systemName: "plus")
            }
        }
    }

    struct PlanView: View {
        let plan: PayInPlan

        var body: some View {
            HStack {
                VStack(alignment: .leading) {
                    Text("every ") + Text(plan.offtenType.localized)
                    Text(plan.money.formattedCurrency())
                }
                Spacer()

                Text(plan.untilYear)
                    .font(.title)
            }
        }
    }
}
