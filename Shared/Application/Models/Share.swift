//
//  Share.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation

struct Share: Codable {
    let figi: String
    let ticker: String?
    let name: String?
    let classCode: String?
    let lot: Int?
    let isin: String?
    let currency: Price.Currency

    let nominal: Price?
    let tradingStatus: TradingStatus?
    let shareType: ShareType?

    /*
     let klong : Double?
     let kshort : Double?
     let dshort : Double?
     let dlong : Double?
     let dlongMin : Double?
     let dshortMin : Double?

     let shortEnabledFlag : Bool?
     let sector : String?

     let countryOfRisk : String?
     let countryOfRiskName : String?

     let issueSizePlan : String?

     let sellAvailableFlag : Bool?
     let buyAvailableFlag : Bool?
     let apiTradeAvailableFlag : Bool?
     let otcFlag : Bool?
     let divYieldFlag : Bool?

     let minPriceIncrement : Double?

     let issueSize : String?
     let exchange : String?
      */
}

extension Share {
    init(from realmShare: RealmShare) {
        figi = realmShare.figi ?? ""
        name = realmShare.name
        ticker = realmShare.ticker
        classCode = realmShare.classCode
        lot = realmShare.lot
        isin = realmShare.isin
        currency = Price.Currency(rawValue: realmShare.currency) ?? .usd
        nominal = realmShare.nominal.map(Price.init)
        tradingStatus = TradingStatus(rawValue: realmShare.tradingStatus ?? "")
        shareType = ShareType(rawValue: realmShare.shareType ?? "")
    }
}

extension Share {
    enum ShareType: String, Codable {
        case SHARE_TYPE_UNSPECIFIED, SHARE_TYPE_COMMON, SHARE_TYPE_PREFERRED, SHARE_TYPE_ADR, SHARE_TYPE_GDR, SHARE_TYPE_MLP, SHARE_TYPE_NY_REG_SHRS, SHARE_TYPE_CLOSED_END_FUND, SHARE_TYPE_REIT
    }

    enum TradingStatus: String, Codable {
        case SECURITY_TRADING_STATUS_UNSPECIFIED, SECURITY_TRADING_STATUS_NOT_AVAILABLE_FOR_TRADING, SECURITY_TRADING_STATUS_OPENING_PERIOD, SECURITY_TRADING_STATUS_CLOSING_PERIOD, SECURITY_TRADING_STATUS_BREAK_IN_TRADING, SECURITY_TRADING_STATUS_NORMAL_TRADING, SECURITY_TRADING_STATUS_CLOSING_AUCTION, SECURITY_TRADING_STATUS_DARK_POOL_AUCTION, SECURITY_TRADING_STATUS_DISCRETE_AUCTION, SECURITY_TRADING_STATUS_OPENING_AUCTION_PERIOD, SECURITY_TRADING_STATUS_TRADING_AT_CLOSING_AUCTION_PRICE, SECURITY_TRADING_STATUS_SESSION_ASSIGNED, SECURITY_TRADING_STATUS_SESSION_CLOSE, SECURITY_TRADING_STATUS_SESSION_OPEN, SECURITY_TRADING_STATUS_DEALER_NORMAL_TRADING, SECURITY_TRADING_STATUS_DEALER_BREAK_IN_TRADING, SECURITY_TRADING_STATUS_DEALER_NOT_AVAILABLE_FOR_TRADING
    }
}
