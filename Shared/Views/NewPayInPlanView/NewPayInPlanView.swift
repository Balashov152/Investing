//
//  PlansPayInView.swift
//  Investing
//
//  Created by Sergey Balashov on 29.04.2021.
//

import Combine
import InvestModels
import SwiftUI
import UIKit

struct NewPayInPlanView: View {
    typealias OfftenType = NewPayInPlanViewModel.OfftenType
    @ObservedObject var viewModel: NewPayInPlanViewModel
//    @SwiftUI.Environment(\.presentationMode) var mode: Binding<PresentationMode>

    func appear() {
        viewModel.didSave = { _ in
//            DispatchQueue.main.async {
//                self.mode.wrappedValue.dismiss()
//            }
        }
    }

    var body: some View {
        ScrollView(.vertical) {
            howOften
                .padding(EdgeInsets(top: 32, leading: 16, bottom: 8, trailing: 16))
            howMuch
                .padding(EdgeInsets(top: 32, leading: 16, bottom: 8, trailing: 16))
            if let newPlan = viewModel.newPlan {
                resultView(string: newPlan.untilYear)
                    .padding(EdgeInsets(top: 32, leading: 16, bottom: 8, trailing: 16))
            }
        }
        .navigationTitle("Plans pay in")
        .navigationBarItems(trailing: saveButton)
        .onAppear(perform: appear)
    }

    var howOften: some View {
        VStack(alignment: .leading) {
            Text("How often?".localized)
                .font(.system(size: 15)).bold()
                .textCase(.uppercase)

            Picker("", selection: $viewModel.selectionOfften, content: {
                ForEach(OfftenType.allCases, id: \.self) { type in
                    Text(type.localized)
                }
            })
            .pickerStyle(SegmentedPickerStyle())
            .labelsHidden()
        }
    }

    var howMuch: some View {
        VStack(alignment: .leading) {
            Text("How much?".localized)
                .font(.system(size: 15)).bold()
                .textCase(.uppercase)
            HStack {
                Text("money")
                TextField("10000", text: $viewModel.howMuchText)
                    .multilineTextAlignment(.trailing)
                Text("₽")
            }
            Divider()
        }
    }

    func resultView(string: String) -> some View {
        VStack {
            Text("Until year you pay in")
                .font(.title)
            Spacer()
            Text(string)
                .font(.title)
                .bold()
        }
        .multilineTextAlignment(.center)
    }

    var saveButton: some View {
        Button("Save", action: viewModel.savePlan)
    }
}
