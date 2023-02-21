//
//  RealmShare.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation
import RealmSwift

public class RealmShare: Object {
    @Persisted(primaryKey: true) var figi: String?
    @Persisted public var name: String?
    @Persisted public var ticker: String?
    @Persisted public var classCode: String?
    @Persisted public var lot: Int?
    @Persisted public var isin: String?
    @Persisted public var currency: String = ""
    @Persisted public var nominal: RealmPrice?
    @Persisted public var tradingStatus: String?
    @Persisted public var shareType: String?
}

extension RealmShare {
    public static func realmShare(from share: Share) -> RealmShare {
        let realmShare = RealmShare()
        realmShare.figi = share.figi
        realmShare.name = share.name
        realmShare.ticker = share.ticker
        realmShare.classCode = share.classCode
        realmShare.lot = share.lot
        realmShare.isin = share.isin
        realmShare.currency = share.currency.rawValue
        realmShare.nominal = share.nominal.map(RealmPrice.realmPrice(from:))
        realmShare.tradingStatus = share.tradingStatus?.rawValue
        realmShare.shareType = share.shareType?.rawValue

        return realmShare
    }
}
