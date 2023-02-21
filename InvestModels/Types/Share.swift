//
//  Share.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation

public struct Share: Codable {
    public let figi: String
    public let ticker: String?
    public let name: String?
    public let classCode: String?
    public let lot: Int?
    public let isin: String?
    public let currency: Price.Currency

    public let nominal: Price?
    public let tradingStatus: TradingStatus?
    public let shareType: ShareType?

    /*
     public let klong : Double?
     public let kshort : Double?
     public let dshort : Double?
     public let dlong : Double?
     public let dlongMin : Double?
     public let dshortMin : Double?

     public let shortEnabledFlag : Bool?
     public let sector : String?

     public let countryOfRisk : String?
     public let countryOfRiskName : String?

     public let issueSizePlan : String?

     public let sellAvailableFlag : Bool?
     public let buyAvailableFlag : Bool?
     public let apiTradeAvailableFlag : Bool?
     public let otcFlag : Bool?
     public let divYieldFlag : Bool?

     public let minPriceIncrement : Double?

     public let issueSize : String?
     public let exchange : String?
      */
}

extension Share {
    public init(from realmShare: RealmShare) {
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

public extension Share {
    enum ShareType: String, Codable {
        case SHARE_TYPE_UNSPECIFIED, SHARE_TYPE_COMMON, SHARE_TYPE_PREFERRED, SHARE_TYPE_ADR, SHARE_TYPE_GDR, SHARE_TYPE_MLP, SHARE_TYPE_NY_REG_SHRS, SHARE_TYPE_CLOSED_END_FUND, SHARE_TYPE_REIT
    }

    enum TradingStatus: String, Codable {
        case SECURITY_TRADING_STATUS_UNSPECIFIED, SECURITY_TRADING_STATUS_NOT_AVAILABLE_FOR_TRADING, SECURITY_TRADING_STATUS_OPENING_PERIOD, SECURITY_TRADING_STATUS_CLOSING_PERIOD, SECURITY_TRADING_STATUS_BREAK_IN_TRADING, SECURITY_TRADING_STATUS_NORMAL_TRADING, SECURITY_TRADING_STATUS_CLOSING_AUCTION, SECURITY_TRADING_STATUS_DARK_POOL_AUCTION, SECURITY_TRADING_STATUS_DISCRETE_AUCTION, SECURITY_TRADING_STATUS_OPENING_AUCTION_PERIOD, SECURITY_TRADING_STATUS_TRADING_AT_CLOSING_AUCTION_PRICE, SECURITY_TRADING_STATUS_SESSION_ASSIGNED, SECURITY_TRADING_STATUS_SESSION_CLOSE, SECURITY_TRADING_STATUS_SESSION_OPEN, SECURITY_TRADING_STATUS_DEALER_NORMAL_TRADING, SECURITY_TRADING_STATUS_DEALER_BREAK_IN_TRADING, SECURITY_TRADING_STATUS_DEALER_NOT_AVAILABLE_FOR_TRADING
    }
}
