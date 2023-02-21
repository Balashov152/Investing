//
//  AppCoordinator.swift
//  Investing
//
//  Created by Sergey Balashov on 21.02.2023.
//

import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var tabBarViewModel: TabBarViewModel?
    
    private let modulesFactory: ModuleFactoring
    
    init(modulesFactory: ModuleFactoring) {
        self.modulesFactory = modulesFactory
        
        tabBarViewModel = modulesFactory.tabBarModule()
    }
    
    func show() {
        
    }
}
