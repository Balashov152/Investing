//
//  HomeView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import SwiftUI
import Combine
import Moya

class HomeViewModel: MainCommonViewModel {}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.mainViewModel.positions, id: \.self) {
                PositionRowView(position: $0)
            }.navigationBarTitle("Tinkoff")
        }
    }
}
