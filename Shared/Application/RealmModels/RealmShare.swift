//
//  RealmShare.swift
//  Investing
//
//  Created by Sergey Balashov on 27.01.2022.
//

import Foundation
import RealmSwift

class RealmShare: Object {
    @Persisted(primaryKey: true) var figi: String?
    @Persisted var name: String?
    @Persisted var ticker: String?
    @Persisted var classCode: String?
    @Persisted var lot: Int?
    @Persisted var isin: String?
    @Persisted var currency: String?
    @Persisted var nominal: RealmPrice?
    @Persisted var tradingStatus: String?
    @Persisted var shareType: String?
}

extension RealmShare {
    static func realmShare(from share: Share) -> RealmShare {
        let realmShare = RealmShare()
        realmShare.figi = share.figi
        realmShare.name = share.name
        realmShare.ticker = share.ticker
        realmShare.classCode = share.classCode
        realmShare.lot = share.lot
        realmShare.isin = share.isin
        realmShare.currency = share.currency?.rawValue
        realmShare.nominal = share.nominal.map(RealmPrice.realmPrice(from:))
        realmShare.tradingStatus = share.tradingStatus?.rawValue
        realmShare.shareType = share.shareType?.rawValue

        return realmShare
    }
}
