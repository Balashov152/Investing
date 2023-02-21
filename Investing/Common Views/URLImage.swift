//
//  URLImage.swift
//  Investing
//
//  Created by Sergey Balashov on 22.01.2021.
//

import Foundation
import InvestModels
import Kingfisher
import SwiftUI

//extension Position: LogoPosition {}

struct URLImage: View {
    let position: LogoPosition

    @State var text: String?

    init(position: LogoPosition) {
        self.position = position
    }

    var body: some View {
        if let text = text {
            Text(text)
        } else if let url = InstrumentLogoService.logoUrl(for: position) {
            KFImage(url)
                .resizable()
                .cancelOnDisappear(true)
                .placeholder {
                    ProgressView()
                }
                .onProgress { _, _ in }
                .onSuccess { _ in }
                .onFailure { _ in
                    self.text = String(position.ticker.first ?? Character(""))
                }
        } else {
            Text("E")
                .background(Color.litleGray)
        }
    }
}

import Foundation
import InvestModels

protocol LogoPosition {
    var instrumentType: InstrumentType { get }
    var ticker: String { get }
    var isin: String? { get }
    var currency: Currency { get }
    var uiCurrency: UICurrency { get }
}

extension LogoPosition {
    var currency: Currency {
        Currency(rawValue: uiCurrency.rawValue.uppercased()) ?? .USD
    }

    var uiCurrency: UICurrency {
        UICurrency(currency: currency) ?? .usd
    }
}

enum InstrumentLogoService {
    static func logoUrl(for model: LogoPosition) -> URL? {
        switch model.instrumentType {
        case .Stock, .Bond:
            guard let isin = model.isin else {
                return nil
            }

            return LogoService.logoUrl(for: isin)

        case .Currency:
            return LogoService.logoUrl(for: model.currency.rawValue)

        case .Etf:
            return LogoService.logoUrl(for: model.ticker)
        }
    }
}

enum LogoService {
    static let base = "https://static.tinkoff.ru/brands/traiding/"
    static func logoUrl(for isin: String) -> URL {
        URL(string: base + isin + "x160.png")!
    }
}
