//
//  ContentView.swift
//  Shared
//
//  Created by Sergey Balashov on 08.12.2020.
//

import Combine
import CombineMoya
import InvestModels
import Moya
import SwiftUI

class MainViewModel: EnvironmentCancebleObject, ObservableObject {}

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        TabView {
            ViewFactory.homeView()
                .tabItem {
                    VStack {
                        Image(systemName: "dollarsign.circle")
                        Text("Profile")
                    }
                }
            ViewFactory.analyticsView()
                .tabItem {
                    VStack {
                        Image(systemName: "chart.bar.xaxis")
                        Text("Analytics")
                    }
                }

            ViewFactory.operationsView()
                .tabItem {
                    VStack {
                        Image(systemName: "list.bullet")
                        Text("Operations")
                    }
                }
        }
        .accentColor(Color(UIColor.systemOrange))
        // .onAppear(perform: viewModel.loadData)
    }
}

// line.diagonal.arrow 􀫱
// slider.vertical.3 􀟲
//
