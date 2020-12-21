//
//  ContentView.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import SwiftUI
import Combine
import CombineMoya
import Moya


enum TabBarIndex: CaseIterable {
    case home, dividends
}

class MainViewModel: ObservableObject {
    @Published var operations: [Operation] = []
    @Published var positions: [Position] = []
}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        TabView {
            ViewFactory.homeView(mainViewModel: viewModel)
             .tabItem {
                Image(systemName: "phone.fill")
                Text("First Tab")
              }
            ViewFactory.operationsView(mainViewModel: viewModel)
                 .tabItem {
                    Image(systemName: "tv.fill")
                    Text("Second Tab")
                  }
        }
    }
}
