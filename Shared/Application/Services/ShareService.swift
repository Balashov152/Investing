//
//  ShareService.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Combine
import Foundation
import Moya

protocol ShareServing {
    func loadShares() -> AnyPublisher<[Share], Error>
}

struct ShareService {
    let provider = ApiProvider<ShareAPI>()
}

extension ShareService: ShareServing {
    func loadShares() -> AnyPublisher<[Share], Error> {
        provider.request(.loadShares(status: .INSTRUMENT_STATUS_UNSPECIFIED))
            .map([Share].self, at: .instruments, using: .standart)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}

enum ShareAPI: TargetType {
    case loadShares(status: ShareStatus)

    var baseURL: URL {
        URL(string: "https://invest-public-api.tinkoff.ru/rest/")!
    }

    var method: Moya.Method { .post }

    var path: String {
        switch self {
        case .loadShares:
            return "tinkoff.public.invest.api.contract.v1.InstrumentsService/Shares"
        }
    }

    var task: Task {
        switch self {
        case let .loadShares(status):
            return .requestCompositeParameters(bodyParameters: ["instrumentStatus": status.rawValue],
                                               bodyEncoding: JSONEncoding.default,
                                               urlParameters: [:])
        }
    }
}

extension ShareAPI {
    enum ShareStatus: String {
        case INSTRUMENT_STATUS_UNSPECIFIED, INSTRUMENT_STATUS_BASE, INSTRUMENT_STATUS_ALL
    }
}
