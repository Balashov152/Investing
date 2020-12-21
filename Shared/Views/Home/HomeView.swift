//
//  HomeView.swift
//  Investing
//
//  Created by Sergey Balashov on 08.12.2020.
//

import SwiftUI
import Combine
import Moya

class HomeViewModel: ObservableObject {
    weak var mainViewModel: MainViewModel?
    
    let service = AccountService()
    let positionService = PositionsService()
    
    @Published var account: Account?
//    @Published var positions: [Position] = []
    
    var cancellables = Set<AnyCancellable>()
    
    init(mainViewModel: MainViewModel) {
        self.mainViewModel = mainViewModel
    }
    
    public func loadData() {
        service.getBrokerAccount()
            .print("getProfile")
            .replaceError(with: nil)
            .assign(to: \.account, on: self)
            .store(in: &cancellables)
        
        positionService.getPositions()
            .map { $0.filter {$0.instrumentType != .some(.Currency) } }
//            .eraseToAnyPublisher()
            .replaceError(with: [])
            .assign(to: \.positions, on: mainViewModel!)
            .store(in: &cancellables)
        
//        let formatter = ISO8601DateFormatter()
//        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]
//        print("ISO8601DateFormatter", formatter.date(from: "2019-08-19T18:38:33.131642+03:00"))
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.mainViewModel!.positions, id: \.self) { (position) -> PositionRowView in
                PositionRowView(position: position)
            }.navigationBarTitle("Tinkoff")
        }.onAppear(perform: viewModel.loadData)
    }
}

extension JSONDecoder {
    static var standart: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .customISO8601
        return decoder
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let customISO8601 = custom {
        let container = try $0.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = Formatter.iso8601withFractionalSeconds.date(from: string) ?? Formatter.iso8601.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date: \(string)")
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    static let iso8601: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
