//
//  PlansPayInView.swift
//  Investing
//
//  Created by Sergey Balashov on 29.04.2021.
//

import Combine
import InvestModels
import SwiftUI

class PlansPayInViewModel: EnvironmentCancebleObject, ObservableObject {}

struct PlansPayInView: View {
    @ObservedObject var viewModel: PlansPayInViewModel

    var body: some View {
        List {}
    }
}
