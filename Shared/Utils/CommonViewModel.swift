//
//  CommonViewModel.swift
//  Investing
//
//  Created by Sergey Balashov on 21.12.2020.
//

import Foundation
import Combine
import SwiftUI

open class CancebleObservableObject: ObservableObject {
    public var cancellables = Set<AnyCancellable>()
}

class MainCommonViewModel: CancebleObservableObject {
    @ObservedObject var mainViewModel: MainViewModel
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
}
