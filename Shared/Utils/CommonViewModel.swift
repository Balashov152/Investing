//
//  CommonViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Combine
import Foundation
import SwiftUI

open class CancebleObservableObject: ObservableObject {
    public var cancellables = Set<AnyCancellable>()
}

class MainCommonViewModel: CancebleObservableObject {
    unowned var mainViewModel: MainViewModel
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
}
